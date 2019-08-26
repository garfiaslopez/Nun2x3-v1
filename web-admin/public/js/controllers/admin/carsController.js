angular.module('CarsCtrl',[]).controller('CarsController',function($scope,$mdDialog,CarwashVars,CarServ,CarwashServ){

	var self = this;

	var Profile = CarwashVars.GetUser();
	console.log(Profile);

	//initialize 'seccion'
	self.Carro = {
		denomination: null,
		price: null,
		lavado_id: null
	}

	self.Images = [
		{
			name: "Carro",
			value: "CARRO.png"
		},
		{
			name: "Carro Fuera",
			value: "CARRO_FUERA.png"
		},
		{
			name: "Motocicleta",
			value: "MOTOCICLETA.png"
		},
		{
			name: "Taxi",
			value: "TAXI.png"
		},
		{
			name: "Camioneta Chica",
			value: "CAMIONETA_CHICA.png"
		},
		{
			name: "Camioneta Grande",
			value: "CAMIONETA_GRANDE.png"
		},
		{
			name: "Camioneta Fuera",
			value: "CAMIONETA_FUERA.png"
		},
		{
			name: "SSP Chico",
			value: "SSP_CHICO.png"
		},
		{
			name: "SSP Grande",
			value: "SSP_GRANDE.png"
		}
	]

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.Carro.denomination = null;
		self.Carro.price = null;
		self.Carro.lavado_id = null;

		self.isEditing.flag = false;
		self.isEditing.id = null;
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

	function ReloadData(){
		self.CarsOnDB = [];
		if(Profile.rol == "SuperAdministrador"){
			CarServ.All().then(function(data){
				self.CarsOnDB = data.data.cars;
			});

			CarwashServ.All().then(function(data){
				self.CarwashesOnDB = data.data.carwashes;
			});
		}
	}

	ReloadData();

	self.Submit = function(){

		if (self.Carro.denomination != undefined &&
			self.Carro.price != undefined ){

			if(self.isEditing.flag){

				CarServ.Update(self.isEditing.id,self.Carro).then(function(data){

					if(data.data.success){
						Alerta('Vehiculo Actualizado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.data.message);
					}

				}).error(function(data){
					Alerta('Error',data.data.message);
		       	});

			}else{
				CarServ.Create(self.Carro).then(function(data){
					if(data.data.success){

						Alerta('Vehiculo Agregado.',data.data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.data.message);
					}
				}).error(function(data){
					Alerta('Error',data.data.message);
		       	});
			}
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Edit = function(CarDB){

		ClearTextFields();

		self.Carro.denomination = CarDB.denomination;
		self.Carro.price = CarDB.price;
		self.Carro.lavado_id = CarDB.lavado_id._id;

		self.isEditing.flag = true;
		self.isEditing.id = CarDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(CarDB){
		CarServ.Delete(CarDB._id).then(function(data){
			Alerta('Vehiculo Eliminado',data.data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.data.message);
	    });
	}

});
