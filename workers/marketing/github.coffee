cheerio = require 'cheerio'
Base64 = require('js-base64').Base64
INGNORE_PATHS = [
  "bower_components"
  "webpack"
  "bootstrap/docs"
]
INGNORE_FILES = [
  "getbootstrapcom"
  "misosoup.io"
]


module.exports = require("../template") (job)->   
  count = job.attrs.count or 5
  repos_dict = {}
  
  search_repos().map (item)->  
    return item.repository
  
  .filter (search_repo)->    
    if search_repo.full_name in repos_dict
      return false
      
    LIBS.models.PublisherInvite.count({
      where: {
        source: "github"
        data: {
          repo_name: "#{search_repo.owner.login}_#{search_repo.name}"
          pull_request: true
        }
      }
    }).then (count)->
      return count == 0

  .then (repos)->
    return LIBS.helpers.shuffle(repos).slice(0, count)

  .each miza_repo


miza_invite = (repo)->
  LIBS.models.Publisher.findOrCreate({
    where: {
      domain: "github.io"
      name: repo.name
    }
    defaults: {
      owner_id: LIBS.models.defaults.github_user.id
      industry_id: LIBS.models.defaults.github_publisher_industry.id
      miza_endpoint: true 
    }
  }).then (publishers)->  
    publisher = publishers[0]
    publisher.addNetworks LIBS.models.defaults.network_ids
    
    LIBS.models.PublisherInvite.findOrCreate({
      where: {
        source: "github"
        publisher_id: publisher.id
      }
      defaults: {
        data: {
          repo_name: "#{repo.owner.login}_#{repo.name}"
          repo_original_name: repo.name
          pull_request: false
          files: {}
        }
      }
    }).then (invites)->
      invite = invites[0]
      invite.publisher = publisher
      invite.script = miza_script(publisher)
      return invite


miza_repo = (search_repo)->
  miza_invite(search_repo).then (invite)->
    Promise.props({
      invite: invite
      forked_repo: fork_repo(search_repo, invite)
      repo: search_repo
      items: search_repos(search_repo.full_name).filter (item)->
        return is_valid_path(item) and not invite.data.files[item.path]? 
    })
    
  .then (props)->
    # Wait for fork to complete
    new Promise (res, rej)->
      setTimeout (-> res props), 30000
    
  .then (props)->
    console.log props.items.length
    props.items = Promise.map props.items, (item)->
      return fetch_content(props.forked_repo, item).then (file)->
        item.file = file
        return item
    
    .filter (item)->
      return is_valid_file(item.file) 
      
    return Promise.props props
    
  .then (props)->
    console.log props.items.length
    
    Promise.each props.items, (item)->    
      insert_miza(item.file, props.invite.script).then (file)->
        update_content(props.forked_repo, file)
        
      .then ->
        props.invite.data.files[item.path] = true
        props.invite.update({
          data: props.invite.data
        })
        
    .then -> 
      if CONFIG.disable.workers.github.pull_request or props.items.length == 0
        return Promise.resolve()
      
      pull_request(props.repo, props.forked_repo, props.invite)
      
    .then ->
      props.invite.data.pull_request = true
      props.invite.update({
        data: props.invite.data
      })


miza_script = (publisher)->
  return """
  <script type='text/javascript'>           	
    (function(window, base) {
      var script = document.createElement("script");
      script.src = "//" + base + "/c?r=" + Math.random();
      script.async = true;
      document.getElementsByTagName('head')[0].appendChild(script);
    })(window, "#{publisher.key}.misosoup.io");
  </script>
  """


search_repos = (repo, page=1, items=[])->
  query = "cdn.carbonads.com language:HTML" 
  
  if repo?
    query += "+repo:#{repo}"

  LIBS.github.search.code({ 
    q: query
    per_page: 100
    page: page
  }).then (search)->
    items = items.concat search.items
    
    if repo? and items.length < search.total_count
      return search_repos repo, ++page, items
      
    return items


pull_request = (repo, forked_repo, invite)->
  invite_url = "#{CONFIG.web_server.host}/invite/#{invite.key}"

  LIBS.github.pullRequests.create({
    owner: repo.owner.login
    repo: repo.name
    head: "#{CONFIG.github.organization}:master"
    base: "master"
    title: "Increase Carbon ad revenue by 30%"
    body: """
    Hey @#{repo.owner.login},
    
    Awesome choice picking Carbon ads, they are simple and unobtrusive! My friend and I have been working on our spare time a way to increase Carbon revenue by ~30%. 
    
    We realized that ad blockers were taking a huge chunk of our revenue so we built [Miza](https://miza.io). You can think of Miza as a bodyguard for your ads, when Miza is installed, your ads will always appear.
    
    We are currently in a private beta and think you would be a great fit! If you want to give us a try, it's as simple as merging the pull request. Once you have merged the pull request you can view your analytics with this link: [#{invite_url}](#{invite_url})
    
    You can contact me directly if you have any questions at #{CONFIG.general.support.email} Thanks for your time!
    """
  })


fork_repo = (repo, invite)->
  LIBS.github.repos.fork({
    owner: repo.owner.login
    repo: repo.name
    organization: CONFIG.github.organization
  }).then (forked_repo)->
    target_name = "#{repo.owner.login}_#{repo.name}"
    
    if forked_repo.name == target_name
      return forked_repo
      
    LIBS.github.repos.createHook({
      owner: CONFIG.github.organization
      repo: repo.name
      name: "web"
      active: true
      events: [
        "pull_request"
        "issue_comment"
      ]
      config: {
        url: "#{CONFIG.web_server.host}/github/hook/#{invite.key}"
        content_type: "json"
      }
    })
  
    LIBS.github.repos.edit({
      owner: CONFIG.github.organization
      repo: repo.name
      name: target_name
    })
  
  
fetch_content = (repo, item)->
  LIBS.github.repos.getContent({
    owner: repo.owner.login
    repo: repo.name
    path: item.path
    ref: "master"
  }).then (file)->
    file.content = Base64.decode(file.content)
    return file
    
    
update_content = (repo, file)->
  LIBS.github.repos.updateFile({
    owner: repo.owner.login
    repo: repo.name
    path: file.path
    message: "Added Miza to #{file.path}"
    content: Base64.encode(file.content)
    sha: file.sha
  })
    
    
insert_miza = (file, miza_script)->
  Promise.resolve().then ->
    $ = cheerio.load file.content
    ad = $("#_carbonads_js, .carbonad").html()
    file.content = file.content.replace ad, "#{miza_script}\n#{ad}"
    return file
  
  
is_valid_path = (file)->
  for path in INGNORE_PATHS
    if file.path.indexOf(path) > -1
      return false
      
  return true


is_valid_file = (file)->
  for path in INGNORE_FILES
    if file.content.indexOf(path) > -1
      return false
      
  return true


