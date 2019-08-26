angular.module('RouterCtrl',['ngRoute','BillsCtrl','CarsCtrl','CarwashCtrl','DashboardCtrl','HistoryCtrl','IngressCtrl','PaybillsCtrl','ProductsCtrl','ServicesCtrl','SpendsCtrl','UsersCtrl','StockCtrl']).config(function($routeProvider, $locationProvider){

		$routeProvider.when('/Dashboard',{
			templateUrl: '/public/pages/admin/dashboard.html',
			controller: 'DashboardController',
			controllerAs: 'Dashboard'
		}).when('/Carwash',{
			templateUrl:'public/pages/admin/carwash.html',
			controller:'CarwashController',
			controllerAs:'Carwash'

		}).when('/Users',{
			templateUrl:'../public/pages/admin/users.html',
			controller:'UsersController',
			controllerAs:'Users'
		}).when('/Cars',{
			templateUrl:'../public/pages/admin/cars.html',
			controller:'CarsController',
			controllerAs:'Cars'
		}).when('/Services',{
			templateUrl:'../public/pages/admin/services.html',
			controller:'ServicesController',
			controllerAs:'Services'
		}).when('/Products',{
			templateUrl:'../public/pages/admin/products.html',
			controller:'ProductsController',
			controllerAs:'Products'
		}).when('/History',{
			templateUrl:'../public/pages/admin/history.html',
			controller:'HistoryController',
			controllerAs:'History'
		}).when('/Spends',{
			templateUrl:'../public/pages/admin/spends.html',
			controller:'SpendsController',
			controllerAs:'Spends'
		}).when('/Ingress',{
			templateUrl:'../public/pages/admin/ingress.html',
			controller:'IngressController',
			controllerAs:'Ingress'
		}).when('/Stock',{
			templateUrl:'../public/pages/admin/stock.html',
			controller:'StockController',
			controllerAs:'Stocks'
		}).when('/Paybills',{
			templateUrl:'../public/pages/admin/paybills.html',
			controller:'PaybillsController',
			controllerAs:'Paybills'
		}).when('/Bills',{
			templateUrl:'../public/pages/admin/bills.html',
			controller:'BillsController',
			controllerAs:'Bills'
		});

	$locationProvider.html5Mode(true);

});
