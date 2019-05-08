#!/usr/bin/env bash

FILE_NAME="./data/worldcupplayerinfo.tsv"

#The number and percentage of the different age range 
function age_range_info_awk()
{
	awk -F '\t' '
	BEGIN{
		le20=0;
		bt2030=0;
		gt30=0
	}
	NR>1{
		if($6<20){ le20++; }
		else if($6<30){ bt2030++; }
		else {gt30++};
	}
	END{
		num=le20+bt2030+gt30;
		printf("****************************************\n")
		printf("The number and percentage of the different age range\n\n");
		printf("range\tnum\tpercentage\t\n")	
		printf("--------------------------\n")
		printf("(0,20)\t%d\t%.3f%\t\n",le20,le20/num*100);
		printf("[20,30)\t%d\t%.3f%\t\n",bt2030,bt2030/num*100);
		printf("[30,)\t%d\t%.3f%\t\n",gt30,gt30/num*100);
	}' "${FILE_NAME}"
}

function age_range_info_shell()
{
	le20=0
	bt2030=0
	gt30=0
	flag=true
	while IFS=$'\t' read -r -a now_line
	do
		if $flag;then
			flag=false
			continue
		fi
		age=${now_line[5]}
		if [[ ${age} -lt 20 ]];then le20=$((le20+1))
		elif [[ ${age} -lt 30 ]];then bt2030=$((bt2030+1))
		else gt30=$((gt30+1));fi
	done <"${FILE_NAME}"
	num=$((le20+bt2030+gt30));
	printf "****************************************\n"
	printf "The number and percentage of the different age range\n\n"
	printf "range\tnum\tpercentage\t\n"	
	echo "-------------------------"
	printf "(0,20)\t%d\t%.3f%%\t\n" "${le20}" "$(echo "scale=5;${le20}/${num}*100" | bc)"
	printf "[20,30)\t%d\t%.3f%%\t\n" "${bt2030}" "$(echo "scale=5;${bt2030}/${num}*100" | bc)"
	printf "[30,)\t%d\t%.3f%%\t\n" "${gt30}" "$(echo "scale=5;${gt30}/${num}*100" | bc)"
}

#Number and percentage of the different location of the players

function position_info_awk()
{
	awk -F '\t' '
	BEGIN{
		num=0;
	}
	NR>1{
		num_pos[$5]++;
		num++;
	}
	END{
		printf("****************************************\n")
		printf("Number and percentage of the different locations of the players\n\n")
		printf("position\tnum\tpercentage\t\n")	
		printf("----------------------------------\n")
		for(i in num_pos){printf("%-9s\t%d\t%.3f%\n",i,num_pos[i],num_pos[i]/num*100);}
	}' "${FILE_NAME}"
}

function position_info_shell()
{
	
	num=0
	declare -A arr
	flag=true
	while IFS=$'\t' read -r -a now_line
	do
		if $flag;then
			flag=false
			continue
		fi
		pos=${now_line[4]}
		num=$((num+1))
		arr["$pos"]=$((arr["$pos"]+1))
		#if [[ ${age} -lt 20 ]];then le20=$((le20+1))
		#elif [[ ${age} -lt 30 ]];then bt2030=$((bt2030+1))
		#else gt30=$((gt30+1));fi
	done <"${FILE_NAME}"
	printf "****************************************\n"
	printf "Number and percentage of the different locations of the players\n\n"
	printf "position\tnum\tpercentage\t\n"	
	echo "----------------------------------"
	for key in "${!arr[@]}";do
		printf "%-9s\t%d\t%.3f%%\n" "${key}" "${arr[$key]}" "$(echo "scale=5;${arr[$key]}/${num}*100"|bc)"
	done	
}

#Get the longest and shortest name
function len_name_awk()
{
	awk -F '\t' '
	BEGIN{
		mx=-1;
		mx_name=""
		mn=9999999;
		mn_name="";
	}
	NR>1{
		ln=length($9);
		if(ln>mx){
			mx=ln;
			mx_name=$9;
		}
		if(ln<mn){
			mn=ln;
			mn_name=$9;
		}
	}
	END{
		printf("****************************************\n")
		printf("Get the longest and shortest name\n\n")
		printf("longest_name:%s\t\n",mx_name)
		printf("shortest_name:%s\t\n",mn_name)
	}' "${FILE_NAME}"
}

function len_name_shell()
{
	
	num=0
	mx=-1
	mx_name=""
	mn=9999999
	mn_name=""
	flag=true
	while IFS=$'\t' read -r -a now_line
	do
		if $flag;then
			flag=false
			continue
		fi
		name=${now_line[8]}
		ln=${#name}
		num=$((num+1))
		#if [[ ${age} -lt 20 ]];then le20=$((le20+1))
		#elif [[ ${age} -lt 30 ]];then bt2030=$((bt2030+1))
		#else gt30=$((gt30+1));fi
		if [[ ${ln} -gt ${mx} ]];then
			mx=${ln}
			mx_name="${name}" 
		fi
		if [[ ${ln} -lt ${mn} ]];then
			mn=${ln}
			mn_name="${name}" 
		fi
		
	done <"${FILE_NAME}"
	printf "****************************************\n"
	printf "Get the longest and shortest name\n\n"
	printf "longest_name:%s\t\n"  "${mx_name}"
	printf "shortest_name:%s\t\n"  "${mn_name}"

}

#Get the ythe oldestand youngest  people
function age_info_awk()
{
	awk -F '\t' '
	BEGIN{
		mx=-1;
		mx_name=""
		mn=9999999;
		mn_name="";
	}
	NR>1{
		if($6>mx){
			mx=$6;
			mx_name=$9;
		}
		if($6<mn){
			mn=$6;
			mn_name=$9;
		}
	}
	END{
		printf("****************************************\n")
		printf("Get the oldest and youngest people\n\n")
		printf("oldest_age:%d\tname:%s\t\n",mx,mx_name)
		printf("youngest_age:%d\tname:%s\t\n",mn,mn_name)
	}' "${FILE_NAME}"
}

function age_info_shell()
{
	mx=-1
	mx_name=""
	mn=9999999
	mn_name=""
	flag=true
	while IFS=$'\t' read -r -a now_line
	do
		if $flag;then
			flag=false
			continue
		fi
		age=${now_line[5]}
		name=${now_line[8]}
		#if [[ ${age} -lt 20 ]];then le20=$((le20+1))
		#elif [[ ${age} -lt 30 ]];then bt2030=$((bt2030+1))
		#else gt30=$((gt30+1));fi
		if [[ ${age} -gt ${mx} ]];then
			mx=${age}
			mx_name="${name}" 
		fi
		if [[ ${age} -lt ${mn} ]];then
			mn=${age}
			mn_name="${name}" 
		fi
		
	done <"${FILE_NAME}"
	printf "****************************************\n"
	printf "Get the oldest and youngest people\n\n"
	printf "oldest_age:%d\tname:%s\t\n" "${mx}" "${mx_name}"
	printf "youngest_age:%d\tname:%s\t\n" "${mn}" "${mn_name}"

}

function main_awk()
{
	age_range_info_awk
	position_info_awk
	len_name_awk
	age_info_awk
}

function main_shell()
{
	age_range_info_shell
	position_info_shell
	len_name_shell
	age_info_shell
}

main_awk
main_shell

