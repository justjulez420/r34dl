#!/bin/bash

tag=$1
mkdir $tag
curl "https://rule34.xxx/index.php?page=post&s=list&tags=$tag&pid=0" -o cache.html
curl "https://rule34.xxx/index.php?page=tags&s=list&tags=$tag+&sort=asc&order_by=updated" -o taglist.html
tag_count=$(grep $tag taglist.html | cut -d '<' -f 3 | tail -n 1 | sed 's/[^0-9]*//g')
rm taglist.html
downloaded=0
echo $downloaded $tag_count

while [ "$downloaded" -lt "$tag_count" ]
do
	curl "https://rule34.xxx/index.php?page=post&s=list&tags=$tag&pid=$downloaded" -o pagecache.html
	img_urls=$(grep "a id" pagecache.html | cut -d '"' -f 4)
	for url in $img_urls
	do
		id=$(echo $url | cut -d '=' -f 4)
		curl "https://rule34.xxx/$url" -o $url.html
		img=$(grep "img alt" $url.html | grep -io 'src=['"'"'"][^"'"'"']*['"'"'"]' | cut -d '"' -f 2)
		format=$(echo $img | rev | cut -d "." -f 1 | rev | cut -d "?" -f 1)
		curl $img -o $tag/$id.$format
		downloaded=$((downloaded+1))
		echo "Downloaded $downloaded of $tag_count Images..."
		rm $url.html
	done
done
rm pagecache.html
rm cache.html
