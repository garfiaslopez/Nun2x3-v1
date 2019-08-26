module.exports = function(root,app,express){

	function AdministerPage(req,res){
		res.sendFile(root + '/public/pages/index.html');
	}

	function LoginPage(req,res){
		res.sendFile(root + '/public/pages/login.html');
	}

	function MainPage(req,res){

		res.sendFile(root + '/public/pages/index.html');

	}

	//STATIC ROUTES:
	app.use("/public", express.static(root + "/public"));
	app.use("/bower_components", express.static(root + "/bower_components"));

	app.get('/',MainPage);

	app.get("/login",LoginPage);

	//put the index to homepage
	app.get("/dashboard",AdministerPage);


	app.get('*',MainPage);


}
