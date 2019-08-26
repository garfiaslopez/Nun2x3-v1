angular.module('ServicesCtrl',[]).controller('ServicesController',function($scope,$mdDialog,CarwashVars,ServServ,CarwashServ){

	var self = this;

	var Profile = CarwashVars.GetUser();
	console.log(Profile);

	//initialize 'seccion'
	self.Servicio = {
		denomination: null,
		price: null,
		lavado_id: null
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	self.Images = [
		{
			name:"Servicio",
			value:"SERVICIO1.png"
		}
	]

	function ClearTextFields(){

		self.Servicio.denomination = null;
		self.Servicio.price = null;
		self.Servicio.lavado_id = null;

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
		self.ServicesOnDB = [];
		if(Profile.rol == "SuperAdministrador"){
			ServServ.All().then(function(data){
				self.ServicesOnDB = data.data.services;
			});
			CarwashServ.All().then(function(data){
				self.CarwashesOnDB = data.data.carwashes;
			});
		}
	}

	ReloadData();

	self.Submit = function(){

		if (self.Servicio.denomination != undefined &&
			self.Servicio.price != undefined ){

			if(self.isEditing.flag){

				ServServ.Update(self.isEditing.id,self.Servicio).then(function(data){

					if(data.data.success){
						Alerta('Servicio Actualizado.',data.data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.data.message);
					}

				}).error(function(data){
					Alerta('Error',data.data.message);
		       	});

			}else{
				ServServ.Create(self.Servicio).then(function(data){
					if(data.data.success){

						Alerta('Servicio Agregado.',data.data.message);

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

	self.Edit = function(ServDB){

		ClearTextFields();

		self.Servicio.denomination = ServDB.denomination;
		self.Servicio.price = ServDB.price;
		self.Servicio.lavado_id = ServDB.lavado_id._id;

		self.isEditing.flag = true;
		self.isEditing.id = ServDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(ServDB){
		ServServ.Delete(ServDB._id).then(function(data){
			Alerta('Servicio Eliminado',data.data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.data.message);
	    });
	}

});
