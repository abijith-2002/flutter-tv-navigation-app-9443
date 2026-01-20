
[ -z "$1" ] && echo "empty commit msg" && exit
git add -A && git commit -m "$1" && git push
