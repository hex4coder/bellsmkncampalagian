echo "Mengupdate dengan judul : $1"
git add .
git commit -m "$1" -a
git push origin master
