angular.module('SpendsCtrl',[]).controller('SpendsController',function($scope,$mdDialog,CarwashVars,SpendServ){

	var self = this;

	var Profile = CarwashVars.GetUser();
	console.log(Profile);
	
	var CarwashActive = CarwashVars.GetCarwash();
	console.log(CarwashActive);
	
	$scope.$on('ChangeCarwash', function (event, data) {
    	console.log(data);
    	CarwashActive = data;
  		//Initial Search...
  	});
	//DatePickerConfiguration:
	self.options = {
	  	format: 'yyyy-mm-dd', 
	  	formatSubmit: 'yyyy-mm-dd',
		monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
		monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
		weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'],
		weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
		today: 'Hoy',
		clear: 'Cerrar',
		firstDay: 1
	}


	function Alerta(title, message){

		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	//vars Initialization:
	self.FilterSelected = "0";
	self.DisableRange=true;

	if(Profile.rol == "SuperAdministrador"){
		self.CanDelete = true;
	}else{
		self.CanDelete = false;
	}

	//i cant reset the dates for the picker.....
	function ClearDateTexts(){
		self.FechaInicio = undefined;
		self.FechaFinal = undefined;
	}

	self.FilterChanged = function(){
		console.log(self.FilterSelected);
		if(self.FilterSelected == 4){
			self.DisableRange=false;
		}else{
			ClearDateTexts();
			self.DisableRange=true;
		}
	}

	function ReloadData(){
		//UserID o CARWASHID
		//FECHA o FILTRO
		var initialDate;
		var finalDate;
		self.isLoading = true;
		switch (self.FilterSelected) {
		    case "0":
				initialDate = moment().format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');		        
				break;
		    case "1":
				initialDate = moment().startOf('isoweek').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
				break;
		    case "2":
				initialDate = moment().startOf('month').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
		        break;
		    case "3":
				initialDate = moment().startOf('year').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
		        break;
		    case "4":
		    	console.log("ini: " + self.FechaInicio + "  fin: " + self.FechaFinal);
				initialDate = moment(self.FechaInicio).format('YYYY-MM-DD');
				finalDate = moment(self.FechaFinal).add(1,'days').format('YYYY-MM-DD');
		        break;
		}

		if(CarwashActive == 0){
			//byaccount

			SpendServ.AllByAccount(Profile.id,initialDate,finalDate).success(function(data){
				if(data.success){
					self.SpendsOnDB = data.spends;
					self.CountSpends = self.SpendsOnDB.length;
					var total = 0;
					angular.forEach(self.SpendsOnDB, function(spend, key) {
						total = total + spend.total;
						spend.date = moment(spend.date).format('YYYY-MM-DD');
					});
					self.TotalSpends = total;
				}else{
					Alerta('Error',data.message);
				}
			}).error(function(data){
				Alerta('Error',data.message);
	       	});
		}else{
			//byCarwash
			SpendServ.AllByLavado(CarwashActive,initialDate,finalDate).success(function(data){
				if(data.success){
					self.SpendsOnDB = data.spends;
					self.CountSpends = self.SpendsOnDB.length;
					var total = 0;
					angular.forEach(self.SpendsOnDB, function(spend, key) {
						total = total + spend.total;
						spend.date = moment(spend.date).format('YYYY-MM-DD');
					});
					self.TotalSpends = total;
				}else{
					Alerta('Error',data.message);
				}
			}).error(function(data){
				Alerta('Error',data.message);
	       	});
		}
	}

	ReloadData();


	self.Search = function(){

		ReloadData();

	}



});