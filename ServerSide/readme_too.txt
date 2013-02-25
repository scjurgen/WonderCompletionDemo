
// This part contains server side scripts, but is also used to populate the app side sqlite-db.
// Before populating check the tablenames
// JS  2013


to populate db run:

php parseWorldHeritage.php | sqlite3 ../WonderCompletionDemo/Assets/WonderCompletionDemo.sqlite

