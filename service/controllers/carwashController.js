//MODELS
var LavadoModel = require("../models/carwash");
var UserModel = require("../models/user");

module.exports = {

	AddNewLavado: function(req,res){

		var TokenObj = req.decoded;
		var Lavado = new LavadoModel();

		if (TokenObj.rol == "SuperAdministrador") {

			Lavado.info.name = req.body.name;
			Lavado.info.address = req.body.address;
			Lavado.info.phone = req.body.phone;
			Lavado.info.type = req.body.type;

			Lavado.save(function(err){

				if(err){

					//entrada duplicada
					if(err.code == 11000){
						return res.json({success: false , message: "Ya existe un lavado con ese nombre."});
					}else{
						return res.json({success:false,error:err});

					}
				}

				res.json({success: true , message:"Lavado Agregado Existosamente."});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},

	AllLavados: function(req,res){

		LavadoModel.find(req.params.user_id, function(err, Lavados) {

			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , carwashes:Lavados});
		});
	},

	AllLavadosByAccount: function(req,res){
		UserModel.findById(req.params.user_id).populate('lavado_id').exec( function(err,Usuario){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , carwashes: Usuario.lavado_id});
		});
	},
	SearchLavadoById: function(req,res){

		LavadoModel.findById( req.params.lavado_id, function(err,Lavado){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , carwash:Lavado});
		});
	},

	UpdateLavadoById: function(req,res){
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			LavadoModel.findById( req.params.lavado_id, function(err, Lavado){
				//some error
				if(err){
					res.json({success:false,error:err});
				}
				//Getting the values from the body request and putting on the user recover from mongo
				if(req.body.name){
					Lavado.info.name = req.body.name;
				}
				if (req.body.phone){
					Lavado.info.phone = req.body.phone;
				}
				if(req.body.address){
					Lavado.info.address = req.body.address;
				}
				if(req.body.type){
					Lavado.info.type = req.body.type;
				}

				//Salvar el usuario actualizado en la DB.
				Lavado.save(function(err){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Datos De Lavado Actualizado"});
				});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	DeleteLavadoById: function(req,res){
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			LavadoModel.remove(
				{
					_id: req.params.lavado_id
				},
				function(err,Lavado){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Lavado Borrado Satisfactoriamente"});
				}
			);
		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},


}
