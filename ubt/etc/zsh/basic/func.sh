
tard() {
	dir=$1
	if [ -z "$1" ]; then
		echo "Please enter the dir name"
		return 1;
	fi
	if [ ! -d "$dir" ]; then
		echo "$dir is not a directory!"
		return 1;
	fi
	tar -czvf "${dir}-$(date "+%Y%m%d%H%M")".tgz $dir
}

