#!/usr/bin/env bash

ARGS=$(getopt -a -o f:q:r:m:p:s:ch -l file:,quality:,resize:,mark:,prefix:,suffix:,convert,help -- "$@")

TOOL_NAME="image_script"
SCRIPT_NAME=""

#Variables
IMAGE_PATH=""
IS_COMPRESS=false
IS_RESIZE=false
IS_CONVERT=false
IS_RENAME=false
IS_PREFIX=false
IS_MARK=false
COMPRESS_QUALITY=100	
RESIZE_SCALE=0
WATERMARK=""
PREFIX=""
SUFFIX=""
CMD=""
PARA=""
TYPE_ARR=("JPG" "PNG" "SVG" "JPEG")
HELP_FLAG=true

#------------------------
function usage(){
cat <<END_EOF
Usage:bash "${SCRIPT_NAME}" -f <filename|path> 
[-q quality] [-r scale_size] [-m watermark] 
[-p prefix] [-s suffix] [-c]

This script is to process images like resize,change images' qualities ans so on.

Arguments Description:
-f,--file                         the file name or path of your images
-q,--quality                      change the compress qualities of jpg/jpeg images
-r,--resize                       resize your jpg/jpeg/svg/png images with original aspect ratio
-m,--mark                         add watermark to jpg/jpeg/png images
-p,--prefix                       add prefix to new images' names
-s,--suffix                       add suffix to new images' names
-c,--convert                      convert png/svg images to jpg images
-h,--help                         show help information

END_EOF

}

eval set -- "${ARGS}"

#check if the "convert" tool is installed
function check_env(){
	if ! type -p convert &>/dev/null;then
		printf '%s\n' "error:convert is not installed"
		exit 1
	fi
}

check_env
SCRIPT_NAME="$0"
#check if the path is valid
function check_path(){
	if ! [[ -d $1 ]] && ! [[ -f $1 ]];then
		echo "$1 is not a valid path"
		exit 1
	fi
}

function error(){
	>&2 echo -e "[ERROR] ${TOOL_NAME}: $1"
	exit 1
}
function warn() {
    >&2 echo -e "[WARN] ${TOOL_NAME}: $1"
}
function check_type(){
	#if [[ $( echo "${TYPE_ARR[@]}" | grep -q "$1" ) ]];then
	#if grep -wq "$1" < echo "${TYPE_ARR[@]}" ;then
	if [[ "${TYPE_ARR[*]}" == *"$1"* ]] ; then
			IS_OK=true
	else
		IS_OK=false
	fi	
}
function calc_intersect(){
	tmp_arr=("$@")
	#mapfile TYPE_ARR <$(comm -12 <(for X in "${tmp_arr[@]}"; do echo "${X}"; done|sort)  <(for X in "${TYPE_ARR[@]}"; do echo "${X}"; done|sort))
	#TYPE_ARR=($(comm -12 <(for X in "${tmp_arr[@]}"; do echo "${X}"; done|sort)  <(for X in "${TYPE_ARR[@]}"; do echo "${X}"; done|sort)))
	mapfile TYPE_ARR < <(comm -12 <(for X in "${tmp_arr[@]}"; do echo "${X}"; done|sort)  <(for X in "${TYPE_ARR[@]}"; do echo "${X}"; done|sort) )
}
function check_size(){
	tmp_size=$1
	if [[ "${tmp_size}" == *[!0-9]* ]];then
		error "Please input an integer!"
	elif [[ ${tmp_size} -le 0 ]];then
		error "Please enter a integer greater than zero"
	fi
}

while [ -n "$1" ]	
do
	case "$1" in
	-f|--file)
		HELP_FLAG=false
		IMAGE_PATH=$2
		check_path "${IMAGE_PATH}"
		shift;;
	-h|--help)
		break
		;;
	-q|--quality)
		HELP_FLAG=false
		IS_COMPRESS=true
		COMPRESS_QUALITY=$2	
		tmp=("JPEG" )
		calc_intersect "${tmp[@]}"
		shift
		;;
	-r|--resize)
		HELP_FLAG=false
		IS_RESIZE=true
		RESIZE_SCALE=$2
		check_size "${RESIZE_SCALE}"
		tmp=("JPEG" "SVG" "PNG")
		calc_intersect "${tmp[@]}"
		shift
		;;
	-m|--mark)
		HELP_FLAG=false
		IS_MARK=true
		WATERMARK=$2
		tmp=("JPEG" "PNG" )
		calc_intersect "${tmp[@]}"
		shift
		;;
	-p|--prefix)
		HELP_FLAG=false
		IS_PREFIX=true
		IS_RENAME=true
		PREFIX=$2
		tmp=("JPEG" "PNG" "SVG")	
		calc_intersect "${tmp[@]}"
		shift
		;;
	-s|--suffix)
		HELP_FLAG=false
		IS_SUFFIX=true
		IS_RENAME=true
		SUFFIX=$2
		tmp=("JPEG" "PNG" "SVG")	
		calc_intersect "${tmp[@]}"
		shift
		;;
	-c|--convert)
		HELP_FLAG=false
		IS_CONVERT=true
		tmp=("PNG" "SVG")
		#echo "${tmp[@]}"
		calc_intersect "${tmp[@]}"
		;;
	--)
		shift
		break
		;;
	esac
shift
done

#main
function main()
{
	if  $HELP_FLAG ;then
		usage
		exit 1
	fi

	if [[ -z "${IMAGE_PATH}"  ]];then
		error "Empty Path!"
	fi
	now_path="${IMAGE_PATH%/*}/"
	file_list=$(ls "${IMAGE_PATH}")
	for now_file in $file_list;do
		now_file_name="${now_file##*/}"
		now_file_type=$(identify -format "%m" "${now_path}${now_file_name}")
		check_type "${now_file_type[@]}"
		if ! $IS_OK;then continue ;fi
		PARA=""
		new_file_name=${now_file_name}
		if  ${IS_COMPRESS} ;then PARA="${PARA} -quality ${COMPRESS_QUALITY} ";fi
		if  ${IS_RESIZE} ;then PARA="${PARA} -resize "${RESIZE_SCALE}%" ";fi
		if  ${IS_CONVERT} ;then new_file_name="${new_file_name%.*}.jpg";fi
		if  ${IS_RENAME} ;then
			if  ${IS_PREFIX} ;then
				new_file_name="${PREFIX}${new_file_name}"
			fi
			if  ${IS_SUFFIX} ;then
				new_file_name="${new_file_name%.*}${SUFFIX}.${new_file_name##*.}"
			fi
		fi
		CMD="convert $now_path$now_file_name $PARA $now_path$new_file_name"
		echo "$CMD"
		eval "${CMD}"
		if  ${IS_MARK} ;then
			convert -size 100x100 xc:none -fill grey -pointsize 10 \
        -gravity NorthWest -draw "text 0,0 '${WATERMARK}'" \
        miff:- |\
  composite -tile -dissolve 50 - "$now_path""$new_file_name"  "$now_path""$new_file_name" 
		fi
	done		
}

main "$@"
