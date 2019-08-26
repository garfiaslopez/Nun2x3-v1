var CarwashService = angular.module('CarwashService',['ngRoute']);

var ApiBase = "http://104.236.74.122:8509";
// var ApiBase = "http://localhost:3000";

CarwashService.factory('Socket', function (socketFactory) {
  var myIoSocket = io.connect(ApiBase);
  mySocket = socketFactory({
    ioSocket: myIoSocket
  });
  return mySocket;
});

CarwashService.service('CarwashVars', function() {

  var Selected = 0;
  var User = {};

  var SetCarwash = function(newValue) {
      Selected = newValue;
  };

  var GetCarwash = function(){
      return Selected;
  };

  var SetUserData = function(user){
  	User = user;
  };

  var GetUserData = function(){
  	return User;
  };

  return {
    SetCarwash: SetCarwash,
    GetCarwash: GetCarwash,
    SetUser: SetUserData,
    GetUser: GetUserData
  };

});


CarwashService.factory("CarwashServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/carwash';
	var BasesUrl = ApiBase + '/carwashes';

	Obj.Create = function(Data){

		return $http.post(BaseUrl, {

			name: Data.name,
			address: Data.address,
			phone: Data.phone,
			type: Data.type


		}).then(function(data){

			return data;

		});
	}

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id){
		var GetUrlByUser = BasesUrl +'/'+ Id;
		return $http.get(GetUrlByUser).then(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = BaseUrl +'/'+ Id;

		return $http.put(UpdateUrl,{

			name: Data.name,
			address: Data.address,
			phone: Data.phone,
			type: Data.type

		}).then(function(data){
			return data;
		});

	}

	Obj.Delete = function(Id){

		var DeleteUrl = BaseUrl +'/'+ Id;

		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});

	}

	return Obj;

});



CarwashService.factory("UserServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/user';
	var BasesUrl = ApiBase + '/users';

	Obj.Create = function(Data){

		return $http.post(BaseUrl, {

			username: Data.username,
			password: Data.password,
			name: Data.name,
			phone: Data.phone,
			address: Data.address,
			rol: Data.rol,
			lavado_id: Data.lavado_id


		}).then(function(data){

			return data;

		});
	}

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByLavado = function(Id){

		var Url = BasesUrl +'/'+ Id;

		return $http.get(Url).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id){

		var Url = BasesUrl +'/byAccount/'+ Id;

		return $http.get(Url).then(function(data){
			return data;
		});
	}
	Obj.Update = function(Id,Data){

		var UpdateUrl = BaseUrl +'/'+ Id;

		return $http.put(UpdateUrl,{

			username: Data.username,
			password: Data.password,
			name: Data.name,
			phone: Data.phone,
			address: Data.address,
			rol: Data.rol,
			lavado_id: Data.lavado_id

		}).then(function(data){
			return data;
		});

	}

	Obj.Delete = function(Id){

		var DeleteUrl = BaseUrl +'/'+ Id;

		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}

	return Obj;

});

CarwashService.factory("CarServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/car';
	var BasesUrl = ApiBase + '/cars';

	Obj.Create = function(Data){
		return $http.post(BaseUrl, {
			denomination: Data.denomination,
			price: Data.price,
            lavado_id: Data.lavado_id,
            img: Data.img

		}).then(function(data){
			return data;
		});
	}
	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}
	Obj.Update = function(Id,Data){

		var UpdateUrl = BaseUrl +'/'+ Id;
		return $http.put(UpdateUrl,{
			denomination: Data.denomination,
			price: Data.price
		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = BaseUrl +'/'+ Id;
		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}
	return Obj;
});


CarwashService.factory("ServServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/service';
	var BasesUrl = ApiBase + '/services';

	Obj.Create = function(Data){
		return $http.post(BaseUrl, {
			denomination: Data.denomination,
			price: Data.price,
            lavado_id: Data.lavado_id,
            img: Data.img
		}).then(function(data){
			return data;
		});
	}
	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}
	Obj.Update = function(Id,Data){

		var UpdateUrl = BaseUrl +'/'+ Id;
		return $http.put(UpdateUrl,{
			denomination: Data.denomination,
			price: Data.price
		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = BaseUrl +'/'+ Id;
		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}
	return Obj;
});



CarwashService.factory("ProductServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/product';
	var BasesUrl = ApiBase + '/products';

	Obj.Create = function(Data){
		return $http.post(BaseUrl, {
			denomination: Data.denomination,
			price: Data.price

		}).then(function(data){
			return data;
		});
	}
	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}
	Obj.Update = function(Id,Data){

		var UpdateUrl = BaseUrl +'/'+ Id;
		return $http.put(UpdateUrl,{
			denomination: Data.denomination,
			price: Data.price
		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = BaseUrl +'/'+ Id;
		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}
	return Obj;
});


CarwashService.factory("SpendServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/spend';
	var BasesUrl = ApiBase + '/spends';

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByLavado = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/byAccount/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){

		var DeleteUrl = BaseUrl +'/'+ Id;

		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}

	return Obj;

});


CarwashService.factory("IngressServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/ingress';
	var BasesUrl = ApiBase + '/ingresses';

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByLavado = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/byAccount/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){

		var DeleteUrl = BaseUrl +'/'+ Id;

		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}

	return Obj;

});

CarwashService.factory("PaybillServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/paybill';
	var BasesUrl = ApiBase + '/paybills';

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByLavado = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/byAccount/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){

		var DeleteUrl = BaseUrl +'/'+ Id;

		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}

	return Obj;

});




CarwashService.factory("StockServ",function($http,$q){

	var Obj = {};

	var BaseUrl = ApiBase + '/stock';
	var BasesUrl = ApiBase + '/stocks';

    Obj.Create = function(Data){

		return $http.post(BaseUrl, {
			lavado_id: Data.lavado_id,
			product: Data.product,
			deliverDate: Data.deliverDate,
			total: Data.total
		}).then(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(BasesUrl).then(function(data){
			return data;
		});
	}

	Obj.AllByLavado = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){

		var Url = BasesUrl +'/byAccount/'+ Id;

		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = BaseUrl +'/'+ Id;
		return $http.delete(DeleteUrl).then(function(data){
			return data;
		});
	}
	return Obj;

});


CarwashService.factory("HistoryServ",function($http,$q){
	var Obj = {};
	var BaseUrl = ApiBase + '/history';

	Obj.AllByLavado = function(Id,initialDate,finalDate,corte_id){
		var Url = BaseUrl +'/'+ Id;
		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate,
            corte_id: corte_id
		}).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){
		var Url = BaseUrl +'/byAccount/'+ Id;
		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	return Obj;

});

CarwashService.factory("DashboardServ",function($http,$q){
	var Obj = {};
	var BaseUrl = ApiBase + '/dashboard';

	Obj.AllByLavado = function(Id,corte_id){
		var Url = BaseUrl +'/'+ Id;
		return $http.post(Url, {
            corte_id: corte_id
		}).then(function(data){
			return data;
		});
	}

	return Obj;
});

CarwashService.factory("TicketAServ",function($http,$q){

	var Obj = {};
	var BaseUrl = ApiBase + '/activetickets';

	Obj.AllByLavado = function(Id){
		var Url = BaseUrl +'/'+ Id;
		return $http.get(Url).then(function(data){
			return data;
		});
	}

	Obj.AllByAccount = function(Id,initialDate,finalDate){
		var Url = BaseUrl +'/byAccount/'+ Id;
		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate

		}).then(function(data){
			return data;
		});
	}

	return Obj;

});

CarwashService.factory("CortesServ",function($http,$q){

	var Obj = {};
	var BaseUrl = ApiBase + '/cortes';
    Obj.AllByLavado = function(Id){
		var Url = BaseUrl +'/'+ Id;
		return $http.post(Url).then(function(data){
			return data;
		});
	}

	return Obj;

});
