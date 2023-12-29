
set "triplet" "g:${env.remote_ip}.${envelope.from}.${envelope.to}";

if eval "!key_exists(SPAM_DB, triplet)" {
    # Greylist sender for 30 days
    eval "key_set(SPAM_DB, triplet, '', 2592000)";
    reject "422 4.2.2 Greylisted, please try again in a few moments.";
    stop;
}
