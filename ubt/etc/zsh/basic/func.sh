
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

search_base() {
    local search_type=$1
    local dir_been_search=$2
    local file_pattern=$3
    if [ -z "$file_pattern" ] ; then
        fmt_error "Empty file_pattern. Dir is $dir_been_search"
        return 1
    fi
    if ! echo "$file_pattern" | grep -q / ; then
        file_pattern="**/$file_pattern"
    fi
    local rst=$(find "$dir_been_search" -wholename "$file_pattern" \
                                        -type ${search_type:0:1})
    if [ -z "$rst" ] ; then
        fmt_error "Can not find $search_type by $file_pattern in dir $dir_been_search"
        return 1
    fi
    if [ 1 -ne $(echo "$rst" | wc -l) ] ; then
        fmt_error "Find multi $search_type by $file_pattern in dir $dir_been_search"
    fi
    echo "$rst" | head -n1
    return
}

search_file() {
    search_base "file" "${@}"
    return $?
}

search_dir() {
    search_base "dir" "${@}"
    return $?
}

search_config_file() {
    search_file $InstallDir/etc "${@}"
    return $?
}

