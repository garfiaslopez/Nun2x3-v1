var app = angular.module('LoginApp',['ngMaterial','AuthService']);


app.config(function($mdIconProvider){

    $mdIconProvider
      .icon("pass", "../public/images/icons/locked57.svg"        , 24)
      .icon("user", "../public/images/icons/account4.svg"    , 24)
      .icon("userlogin", "../public/images/icons/account4.svg"    , 120);


});


app.controller('LoginController',function($scope,$mdDialog,Auth){

	$scope.doLogin = function(loginData) {

		console.log("LoginData: " + loginData);
     	Auth.Login(loginData.username, loginData.password).then(function(data) {

     			console.log(data);

     			if(data.data.success){
					if(data.data.user.rol != "Empleado"){
						window.location = '/';
					}else{
		     			$mdDialog.show(
						      $mdDialog.alert()
						        .parent(angular.element(document.body))
						        .title('Error Al Iniciar Sesion.')
						        .content('No Tienes Los Permisos Para Acceder.')
						        .ariaLabel('Alert Dialog Demo')
						        .ok('OK')
					    );
					}
     			}else{

	     			$mdDialog.show(
					      $mdDialog.alert()
					        .parent(angular.element(document.body))
					        .title('Error Al Iniciar Sesion.')
					        .content(data.message)
					        .ariaLabel('Alert Dialog Demo')
					        .ok('OK')
				    );
     			}
       		}).catch(function(data){
        		$mdDialog.show(
				      $mdDialog.alert()
				        .parent(angular.element(document.body))
				        .title('Error Al Iniciar Sesion.')
				        .content(data.message)
				        .ariaLabel('Alert Dialog Demo')
				        .ok('OK')
			    );
       		});
   	};


});
