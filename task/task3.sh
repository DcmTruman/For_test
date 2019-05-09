#!/usr/bin/env bash 


FILE_NAME="./data/web_log.tsv"



function show_top100_host()
{
	echo "show_top100_host"
	awk -F '\t' '
	NR>1{
		host_num[$1]+=1;
	}
	END{
		for(i in host_num){
			printf("host_name:%-30s\t%d\t\n",i,host_num[i]);
		}
	} 
	' "${FILE_NAME}" | sort -n -r -k 2 | head -n 100
}

function show_top100_ip()
{
	echo "show_top_100_ip"
	awk -F '\t' '
	NR>1{
		if($1~/([0-9]{1,3}\.){3}[0-9]{1,3}/){
			ip_num[$1]+=1;
		}
	}
	END{
		for(i in ip_num){
			printf("ip:%-30s\t%d\t\n",i,ip_num[i]);
		}
	} 
	' "${FILE_NAME}"  | sort -n -r -k 2 | head -n 100
}

function show_top100_url()
{
	echo "show_top100_url"
	awk -F '\t' '
	NR>1{
		url_num[$5]+=1;
	}
	END{
		for(i in url_num){
			printf("url:%-60s\t%d\t\n",i,url_num[i]);
		}
	} 
	' "${FILE_NAME}"  | sort -n -r -k 2 | head -n 100
}

function show_status()
{
	echo "show_status_code"
	awk -F '\t' '
	BEGIN{
		num=0;
	}
	NR>1{
		num+=1;
		status_num[$6]+=1;
	}
	END{
		for(i in status_num){
			printf("status:%d\tnum:%d\tpercentage:%.5f%\t\n",i,status_num[i],status_num[i]*100.0/num);
		}
	} 
	' "${FILE_NAME}" 
}

function show_4xx()
{
	echo "403 top10:"
	awk -F '\t' '
	NR>1{
		if($6~/^403/){
			url_num[$5]+=1;
		}
	}
	END{
		for(i in url_num){
			printf("url:%-50s\t%d\t\n",i,url_num[i]);
		}
	} 
	' "${FILE_NAME}"  | sort -n -r -k 2 | head -n 10
	echo "404 top10:"
	awk -F '\t' '
	NR>1{
		if($6~/^404/){
			url_num[$5]+=1;
		}
	}
	END{
		for(i in url_num){
			printf("url:%-50s\t%d\t\n",i,url_num[i]);
		}
	} 
	' "${FILE_NAME}"  | sort -n -r -k 2 | head -n 10
}

function show_url()
{
	echo "show_url"
	url=$1
	awk -F '\t' '
	NR>1{
		if($5=="'"${url}"'"){
			url_num[$1]+=1;
		}
	}
	END{
		for(i in url_num){
			printf("host:%-30s\t%d\t\n",i,url_num[i]);
		}
	} 
	' "${FILE_NAME}"  | sort -n -r -k 2 | head -n 100
}

function main()
{
	if [[ $# -eq 0 ]];then
		show_top100_host
		show_top100_ip
		show_top100_url
		show_status
		show_4xx
	else
		show_url "$1"
	fi
}

main "$@"
