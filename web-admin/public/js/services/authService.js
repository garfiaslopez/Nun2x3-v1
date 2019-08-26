var AuthServices = angular.module('AuthService',['ngRoute']);


var ApiBase = "http://104.236.74.122:8509";
//var ApiBase = "http://localhost:3000";

AuthServices.factory("Auth",function($http,$q, AuthToken){

	var AuthFactory = {};

	var BaseUrl = ApiBase + '/authenticate';

	AuthFactory.Login = function(username,password){
		return $http.post(BaseUrl , {
			username: username,
			password: password
		}).then(function(data){
			AuthToken.SetToken(data.data.token);
			return data;
		});
	}

	AuthFactory.LogOut = function(){

		AuthToken.SetToken();

	}

	AuthFactory.isLoggedIn = function(){

		if(AuthToken.GetToken()){
			return true;
		}else{
			return false;
		}

	}

	AuthFactory.GetUser = function(){

		if (AuthToken.GetToken()) {
			return $http.get(BaseUrl + '/me');
		}else{

			return $q.reject({message:"User has no token"});

		}
	}

	return AuthFactory;

});


AuthServices.factory("AuthToken", function($window){

	var AuthTokenFactory = {};

	//get the token from localstorage from browser
	AuthTokenFactory.GetToken = function(){

		return $window.localStorage.getItem("Token_Carwash");

	}
	//guardar el token en localstorage:
	AuthTokenFactory.SetToken = function(token){

		if(token){
			$window.localStorage.setItem("Token_Carwash",token);

		}else{

			$window.localStorage.removeItem("Token_Carwash");
		}
	}

	return AuthTokenFactory;

});


AuthServices.factory("AuthInterceptor",function($q, $location, AuthToken){

	var InterceptorFactory = {};

	InterceptorFactory.request = function(config){

		var token = AuthToken.GetToken();

		if(token){

			config.headers["Authorization"] = token;
			config.headers["Content-Type"] = 'application/json';

		}

		return config;

	}

	InterceptorFactory.responseError = function(response){

		if(response.status == 403){
			AuthToken.SetToken();
			$location.path("/");
		}

		return $q.reject(response);

	}

	return InterceptorFactory;


});
