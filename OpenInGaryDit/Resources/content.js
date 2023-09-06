const redditRegex = /^(?:https?:\/\/)?(?:(?:www|amp|m|i)\.)?(?:(?:reddit\.com))\/r\/(\w+)(?:\/comments\/(\w+)(?:\/\w+\/(\w+)(?:\/?.*?[?&]context=(\d+))?)?)?/i;
const match = window.location.href.match(redditRegex);

if (match) {
    
    const subreddit = match[1];
    const postId = match[2];
    const commentId = match[3];
    
    
    window.location.replace(`garydit://open-from-url/${subreddit ?? ""}/${postId ?? ""}/${commentId ?? ""}`);
}
