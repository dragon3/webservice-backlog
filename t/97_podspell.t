use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(<DATA>);
all_pod_files_spelling_ok('lib');
__DATA__
Ryuzo
Yamamoto
YAMAMOTO
countIssue
createIssue
findIssue
getComments
getComponents
getIssue
getProject
getProjects
getUsers
getVersions
switchStatus
updateIssue
API
statusId
