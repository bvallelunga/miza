BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/');
ROOT=$(git rev-parse --show-toplevel)

#bash $ROOT/scripts/npm_prepare.sh;
#git add $ROOT/npm-shrinkwrap.json $ROOT/package.json;
#git commit -m "updated npm-shrinkwrap.json";
git push origin $BRANCH;
git checkout master;
git merge $BRANCH;
git push origin master;
git checkout $BRANCH;