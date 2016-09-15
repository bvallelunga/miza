BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/');

bash ./npm_prepare.sh;
git checkout master;
git merge $BRANCH;
git push origin master;
git checkout $BRANCH;