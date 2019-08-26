angular.module('UsersCtrl',[]).controller('UsersController',function($scope,UserServ,CarwashServ,$mdDialog,CarwashVars){

	var self = this;

	var Profile = CarwashVars.GetUser();
	console.log(Profile);

	//initialize 'seccion'
	self.Usuario = {
		username: null,
		password: null,
		name: null,
		phone: null,
		address: null,
		rol: null,
		lavado_id: null
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	if(Profile.rol == "SuperAdministrador"){
		self.ActiveRoles = true;
		self.Roles = ["Empleado","Administrador","SuperAdministrador"];
	}else{
		self.ActiveRoles = false;
		//self.Roles = ["Empleado","Administrador"];
	}


	function ClearTextFields(){

		self.Usuario.username = null;
		self.Usuario.password = null;
		self.Usuario.name = null;
		self.Usuario.phone = null;
		self.Usuario.address = null;
		self.Usuario.rol = "Empleado";
		self.Usuario.lavado_id = null;

		angular.forEach(self.CarwashesOnDB, function(carwash, key) {
			if(carwash.isSelected){
				carwash.isSelected = null;
			}
		});

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
		self.UsersOnDB = [];
		if(Profile.rol == "SuperAdministrador"){
			UserServ.All().then(function(data){
				self.UsersOnDB = data.data.users;
			});
		}else{
			UserServ.AllByAccount(Profile.id).then(function(data){
				console.log(data);
				self.UsersOnDB = data.data.users;
			});
		}
		self.Usuario.rol = "Empleado";
	}

	ReloadData();

	function ReloadCarwashes(){

		if(Profile.rol == "SuperAdministrador"){
			CarwashServ.All().then(function(data){
				console.log(data);
				self.CarwashesOnDB = data.data.carwashes;
			});
		}else{
			CarwashServ.AllByAccount(Profile.id).then(function(data){
				console.log(data);
				self.CarwashesOnDB = data.data.carwashes;
			});
		}
	}

	ReloadCarwashes();

	self.Submit = function(){

		//add the carwashes selected to the user model
		self.Usuario.lavado_id = [];
		angular.forEach(self.CarwashesOnDB, function(carwash, key) {
			if(carwash.isSelected){
				self.Usuario.lavado_id.push(carwash._id);
			}
		});

		console.log(self.Usuario);

		if (self.Usuario.username != undefined &&
			self.Usuario.password != undefined &&
			self.Usuario.name != undefined &&
			self.Usuario.phone != undefined &&
			self.Usuario.address != undefined &&
			self.Usuario.lavado_id.length > 0 ){

			if(self.isEditing.flag){

				UserServ.Update(self.isEditing.id,self.Usuario).then(function(data){

					if(data.data.success){

						Alerta('Usuario Actualizado.',data.data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.data.message);
					}

				}).error(function(data){
					Alerta('Error',data.data.message);
		       	});

			}else{
				UserServ.Create(self.Usuario).then(function(data){
					if(data.data.success){

						Alerta('Usuario Agregado.',data.data.message);

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

	self.Edit = function(UserDB){

		ClearTextFields();

		self.Usuario.username = UserDB.username;
		self.Usuario.password = UserDB.password;
		self.Usuario.name = UserDB.info.name;
		self.Usuario.phone = UserDB.info.phone;
		self.Usuario.address = UserDB.info.address;
		self.Usuario.rol = UserDB.rol;

		console.log(UserDB);
		angular.forEach(UserDB.lavado_id, function(Lavado, key) {
			angular.forEach(self.CarwashesOnDB, function(carwash, key) {
				if(Lavado == carwash._id){
					carwash.isSelected = true;
				}
			});
		});

		self.isEditing.flag = true;
		self.isEditing.id = UserDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(UserDB){
		UserServ.Delete(UserDB._id).then(function(data){
			Alerta('Usuario Eliminado',data.data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.data.message);
	    });
	}

});
