module.exports.fetch = (req, res, next)->
  LIBS.models.PublisherInvite.findOne({
    where: {
      key: req.params.invite
    }
    include: [{
      model: LIBS.models.Publisher
      as: "publisher"
    }]
  }).then (invite)->
    if not invite?
      return next "Invalid invite key"
      
    req.invite = invite
    next()


module.exports.hook = (req, res, next)->
  event = req.header("X-GitHub-Event")
  action = req.body.action
  
  if event == "issue_comment"
    LIBS.slack.message {
      attachments: [
        {
          pretext: """
          Github Marketing: <#{req.body.issue.user.html_url}|@#{req.body.issue.user.login}> commented on the pull request for <#{req.body.repository.html_url}|#{req.body.repository.name}>. <#{req.body.issue.html_url}|View comment>
          """
          "text": req.body.comment.body
          "mrkdwn_in": [
              "text"
          ]
        }
      ]
    }
  
  if event == "pull_request" and action != "opened"
    if action == "closed" and req.body.pull_request.merged
      action = "merged"
  
    LIBS.slack.message {
      text: """
      Github Marketing: <#{req.body.pull_request.user.html_url}|@#{req.body.pull_request.user.login}> #{action} the pull request for <#{req.body.repository.html_url}|#{req.body.repository.name}>. <#{req.body.pull_request.html_url}|View pull request>
      """
    }
  
  res.send "Message recieved!"