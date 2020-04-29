#!/bin/bash

function handle_line() {
    HAS_FAILED=0
    curl $2 -s -f -m 5 -o /dev/null || HAS_FAILED=1

    if [[ -f "$1" ]]; then
        # has previously failed
        if [[ "$HAS_FAILED" -eq 1 ]]; then
            # still fails.
            url_output=$(sed 's+\/\/.*\@+\/\/+g' <<< $2)
            echo "$url_output is still down"
        else
            # recovery.
            handle_recovery $1 $2 $3
        fi
    else
        # was previously successful
        if [[ "$HAS_FAILED" -eq 1 ]]; then
            # new failure.
            handle_failure $1 $2 $3
        else
            # just works.
            url_output=$(sed 's+\/\/.*\@+\/\/+g' <<< $2)
            echo "$url_output is online"
        fi
    fi
}

function handle_failure() {
    url_output=$(sed 's+\/\/.*\@+\/\/+g' <<< $2)
    date=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$url_output is down at $date"
    echo -e "To: $3\nFrom: $3\nSubject: Alert: Website is down\n\n$url_output is down as of $date\n\n." | ssmtp $3
    echo 'down' > $1
}

function handle_recovery() {
    url_output=$(sed 's+\/\/.*\@+\/\/+g' <<< $2)
    date=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$url_output has recovered at $date"
    echo -e "To: $3\nFrom: $3\nSubject: Alert: Website recovered\n\n$url_output has recovered as of $date\n\n." | ssmtp $3
    rm $1
}

filename='/root/url_list.conf'
email=$(</root/email.conf)

while true
do
    n=1
    while read line; do
      handle_line ${n} ${line} ${email}
      n=$((n+1))
    done < ${filename}
    echo 'sleeping'
    sleep 900
done

