//MODELS
var CarModel = require("../models/car");

module.exports = {

	AddNewCar: function(req,res){

		var TokenObj = req.decoded;
		var Car = new CarModel();

		if (TokenObj.rol == "SuperAdministrador") {

			Car.lavado_id = req.body.lavado_id;
			Car.denomination = req.body.denomination;
			Car.price = req.body.price;
			Car.img = req.body.img;

			Car.save(function(err){

				if(err){
					//entrada duplicada
					if(err.code == 11000){
						return res.json({success: false , message: "Ya existe un vehiculo con ese nombre."});
					}else{
						return res.json({success:false,error:err});
					}
				}

				res.json({success: true , message: Car.denomination + " Agregado Existosamente."});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	AllCars: function(req,res){

		CarModel.find().populate({path: 'lavado_id', select: 'info.name'}).exec(function(err, Cars) {

			if(err){
				res.json({success:false,error:err});
			}
			res.json({success:true,cars:Cars});
		});
	},


	AllCarsByLavado: function(req,res) {
		CarModel.find(
			{
				lavado_id: req.params.lavado_id
			}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Cars){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , cars:Cars});
			});
	},

	SearchCarById: function(req,res){
		CarModel.findById( req.params.car_id, function(err,Car){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success:true,car:Car});
		});
	},

	UpdateCarById: function(req,res){

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			CarModel.findById( req.params.car_id, function(err, Car){
				//some error
				if(err){
					res.json({success:false,error:err});
				}

				//Getting the values from the body request and putting on the user recover from mongo
				if(req.body.denomination){
					Car.denomination = req.body.denomination;
				}
				if (req.body.price){
					Car.price = req.body.price;
				}
				//IMG PENDING

				//Salvar el usuario actualizado en la DB.
				Car.save(function(err){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true ,message:"Datos De vehiculo Actualizado"});
				});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	DeleteCarById: function(req,res){
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			CarModel.remove(
				{
					_id: req.params.car_id
				},
				function(err,Car){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true ,message:"vehiculo Borrado Satisfactoriamente"});
				}
			);
		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},


}
