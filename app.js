const express = require('express')
const app = express()
const path = require('path')
const bodyParser = require('body-parser')
const fs = require('fs')
//var fs= require('fs')
var session=require('express-session'); 
app.use(session({secret:'iloveuit',resave:false,saveUninitialized: false}));
var port=process.env.PORT||3000;



app.use(express.static('public'))
app.set('view engine', 'ejs')
app.set('views', path.join(__dirname, 'views'))
app.use(bodyParser.urlencoded({ extended: false }))

//load tasks array from a file
let loadTasks = function () {
    try {
        let bufferedData = fs.readFileSync('tasks.json')
        let dataString = bufferedData.toString()
        let tasksArray = JSON.parse(dataString)
        return tasksArray
    } catch (error) {
        return []
    }

}

//add a new task to tasks array
let addTask = function (task) {
    //load tasks array
    let tasks = loadTasks()
    //push new task in array
    tasks.push(task)
    //save array back in file
    fs.writeFileSync('tasks.json', JSON.stringify(tasks))
}

app.get('/', function (req, res) {
    res.render('login')
})

app.get('/registration', function (req, res) {
    res.render('registration');
})

app.get('/drama', function (req, res) {
    res.render('drama');
})

app.get('/action', function (req, res) {
    res.render('action');
})
app.get('/horror', function (req, res) {
    res.render('horror');
})
app.get('/godfather', function (req, res) {
    res.render('godfather');
})
app.get('/godfather2', function (req, res) {
    res.render('godfather2');
})
app.get('/scream', function (req, res) {
    res.render('scream');
})
app.get('/conjuring', function (req, res) {
    res.render('conjuring');})

app.get('/fightclub', function (req, res) {
     res.render('fightclub');
    })
 app.get('/darkknight', function (req, res) {
     res.render('darkknight');
    })

 app.get('/watchlist', function (req, res) {
    var watchlistresults = [];
    var a = fs.readFileSync("userss.json");
    var b = JSON.parse(a);
    for (let i = 0; i < b.users.length; i++) {
        if (req.session.username == b.users[i].username ) {
            console.log("im here");
           watchlistresults = b.users[i].watchlist
           console.log("almost there");
        res.render('watchlist',{
           tasks: watchlistresults
        })
        console.log("getting closer");
    }}})
       



app.listen(port, () => {
    console.log('server is running')
})
//var o = { users: [] };
//var s = JSON.stringify(o);
//fs.writeFileSync("userss.json", s);
app.post("/register", function (req, res) {
    var flag = true;
    for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
        if (req.body.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username) {
            flag = false;
        }
    }
    if (flag == true) {
        var watchlist;
        var user = { "username": req.body.username, "password": req.body.password, watchlist: [] }
        //(fs.writeFileSync("userss.json",JSON.stringify(JSON.parse(fs.readFileSync("userss.json")).push(user))));
        var a = fs.readFileSync("userss.json");
        var b = JSON.parse(a);
        b.users.push(user);
        var d = JSON.stringify(b);
        fs.writeFileSync("userss.json", d);
      res.send("Registration is successful");

    } else{
        res.send("another user is already using this username")}
})
app.post("/", function (req, res) {
    var flag = true;
    for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
        if (req.body.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
        if (req.body.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
            req.session.username=req.body.username;
            req.session.password=req.body.password;
            flag = false; 
    }}}

        if (flag == false){
            res.render('home');
        }
        else{
            res.send("sorry the information you entered is not correct");
        }
    })
    app.post("/conjuring",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                    if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="The Conjuring"){
                    res.end("the movie is already in your watchlist");
                    flag=false;}
                    }
                if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('The Conjuring');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end('done');}
               }}}
        
    })

    app.post("/godfather",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                    if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="The God Father"){
                    flag=false;
                    res.end("the movie is already in your watchlist");}
                    }
                if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('The God Father');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end('done');}
               }}}
        
    })

    app.post("/darkknight",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                    if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="The Dark Knight"){
                    res.end("the movie is already in your watchlist");
                    flag=false;}
                    }
                if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('The Dark Knight');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end('done');}
               }}}
        
    })


    app.post("/fightclub",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                    if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="Fight Club"){
                    res.end("the movie is already in your watchlist");
                    flag=false;}
                    }
                    if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('Fight Club');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end('done');}
               }}}
        
    })


    app.post("/godfather2",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                    if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="The God Father 2"){
                    res.end("the movie is already in your watchlist");
                    flag=false;}
                    }
                    if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('The God Father 2');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end("done");}
               }}}
      
    })

    app.post("/scream",function(req,res){
        for (i = 0; i < JSON.parse(fs.readFileSync("userss.json")).users.length; i++) {
            if (req.session.username == JSON.parse(fs.readFileSync("userss.json")).users[i].username ) {
            if (req.session.password == JSON.parse(fs.readFileSync("userss.json")).users[i].password ) {
                var flag=true;
                for (j = 0; j < JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist.length; j++) {
                if( JSON.parse(fs.readFileSync("userss.json")).users[i].watchlist[j]=="Scream"){
                res.end("the movie is already in your watchlist");
                flag=false;}
                }
                if(flag==true){
                var a = fs.readFileSync("userss.json");
                var b = JSON.parse(a);
                b.users[i].watchlist.push('Scream');
                var d = JSON.stringify(b);
                fs.writeFileSync("userss.json", d);
                res.end('done');}
               }}}
        
    })
    app.post('/search',function(req,res){
        let searchresult = []
        let input = ""
        input = req.body.Search
  
        if("godfather".includes(input)){
          searchresult.push("godfather")
   
        }
        if("conjuring".includes(input)){
          searchresult.push("conjuring")
        }
        if("scream".includes(input)){
          searchresult.push("scream")
        }
        if("godfather II".includes(input)){
          searchresult.push("godfather II")
        }
        if("darkknight".includes(input)){
          searchresult.push("darkknight")
        }
        if("fightclub".includes(input)){
          searchresult.push("fightclub")
        }
        if(input == ""){
            searchresult = [];
        }
        console.log(searchresult);
        res.render('searchresults',{x:searchresult});
      })



app.get('/delete', function (req, res) {
    fs.writeFileSync('tasks.json', JSON.stringify([]))
    res.redirect('/')
})

   