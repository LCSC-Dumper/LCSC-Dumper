#!/usr/bin/fish

# This file needs the fish shell to run
	
# set delay in seconds between requests
# I think the rate limit is 30 per minute
# 2 is safe, but probably too much
set delay 2

#unset to show curl output
set curlSilent "-s"

#I think those are all
set cats 308 312 316 319 320 328 348 365 380 385 395 423 440 450 460 470 487 493 500 513 515 570 575 582 601 905 938 953 986 10991 11032

#get cookies
echo "getting cookies"
curl "https://lcsc.com/products/Cables-Accessories_942.html" -c lcsc.cookies $curlSilent > index.html
set X_CSRF_TOKEN "X-CSRF-TOKEN: "(cat index.html |grep "X-CSRF-TOKEN" |sed -e "s/.*TOKEN': '//;s/'.*//")
echo $X_CSRF_TOKEN


function dump
  set c $argv[1] #category
  set p $argv[2] #page
  curl 'https://lcsc.com/api/products/search' $curlSilent\
     -H $X_CSRF_TOKEN \
     -b lcsc.cookies \
     --data-raw "current_page=$p&category=$c&in_stock=false&is_RoHS=false&show_icon=false&search_content=" \
     > $c-$p.json
end

for c in $cats
  dump $c 1
  #set total (jq ".result.total" $c-1.json)
  #set pages (math "ceil($total/25)")
  set total (sed -e "s/.*total\"://;s/,.*//" $c-1.json)
  set pages (sed -e "s/.*total_page\"://;s/,.*//" $c-1.json)
  
  echo "$total in category $c, pages $pages" 
  sleep $delay
  for p in (seq 2 $pages)
    echo dumping cat $c, page $p of $pages
    dump $c $p
    sleep $delay
  end
end

