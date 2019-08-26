//MODELS
var ServiceModel = require("../models/service");

module.exports = {

	AddNewService: function(req,res){

		var TokenObj = req.decoded;
		var Service = new ServiceModel();

		if (TokenObj.rol == "SuperAdministrador") {

			Service.lavado_id = req.body.lavado_id;
			Service.denomination = req.body.denomination;
			Service.price = req.body.price;
			Service.img = req.body.img;			

			Service.save(function(err){

				if(err){
					//entrada duplicada
					if(err.code == 11000){
						return res.json({success: false , message: "Ya existe un servicio con ese nombre."});
					}else{
						return res.json({success:false,error:err});
					}
				}

				res.json({success: true , message:"Servicio Agregado Existosamente."});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	AllServices: function(req,res){

		ServiceModel.find().populate({path: 'lavado_id', select: 'info.name'}).exec(function(err, Services) {

			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , services:Services});
		});
	},


	AllServicesByLavado: function(req,res) {

		ServiceModel.find(
			{
				lavado_id: req.params.lavado_id
			}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Services){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , services:Services});
			});

	},

	SearchServiceById: function(req,res){

		ServiceModel.findById( req.params.service_id, function(err,Service){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , service:Service});
		});
	},

	UpdateServiceById: function(req,res){

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			ServiceModel.findById( req.params.service_id, function(err, Service){
				//some error
				if(err){
					res.json({success:false,error:err});
				}

				//Getting the values from the body request and putting on the user recover from mongo
				if(req.body.denomination){
					Service.denomination = req.body.denomination;
				}
				if (req.body.price){
					Service.price = req.body.price;
				}
				//IMG PENDING

				//Salvar el usuario actualizado en la DB.
				Service.save(function(err){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Datos De Servicio Actualizado"});
				});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	DeleteServiceById: function(req,res){
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			ServiceModel.remove(
				{
					_id: req.params.service_id
				},
				function(err,Service){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Servicio Borrado Satisfactoriamente"});
				}
			);
		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},


}
