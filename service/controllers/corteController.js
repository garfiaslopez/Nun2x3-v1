//MODELS
var CorteModel = require("../models/corte");
var UserModel = require("../models/user");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;


module.exports = {

	AddNewCorte: function(req,res){
		var TokenObj = req.decoded;
		var Corte = new CorteModel();

		Corte.lavado_id = req.body.lavado_id;
		Corte.corte_id = req.body.corte_id;
		Corte.user = req.body.user;
		Corte.date = req.body.date;

		Corte.save(function(err){
			if(err){
				return res.json({success:false,error:err});
			}
			res.json({success: true , message:"Corte Agregado Exitosamente."});
		});
	},
	AllCortes: function(req,res){
		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			CorteModel.find( function(err, Cortes) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , cortes:Cortes});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},
	LastCorteByLavado: function(req, res) {
		CorteModel.findOne({lavado_id: req.params.lavado_id}).sort({created: -1}).exec(function(err, corte) {
			if (err) {
				res.json({success:false,error:err});
			}
			res.json({success:true, corte: corte});
		});
	},
	AllCortesByLavado: function(req,res) {
		CorteModel.find({lavado_id: req.params.lavado_id}).exec(function(err,Cortes){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , cortes:Cortes});
		});
	},


	// ALL CORTES BY ACCOUNT (PENDING)
	// AllTicketsByAccount: function(req,res) {
	//
	// 	var TokenObj = req.decoded;
	//
	// 	if (TokenObj.rol == "SuperAdministrador") {
	//
	// 		if(req.body.initialDate && req.body.finalDate){
	//
	// 			TicketModel.find(
	// 			{
	// 				date: {
	// 			      	$gte: moment(req.body.initialDate),
	// 			      	$lt: moment(req.body.finalDate)
	// 			    }
	// 			}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
	// 				if(err){
	// 					res.json({success:false,error:err});
	// 				}
	// 				res.json({success: true , tickets:Tickets});
	// 			});
	// 		}else{
	// 			var initialDate = moment().format('YYYY-MM-DD');
	// 			var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
	//
	// 			TicketModel.find(
	// 			{
	// 				date: {
	// 			      	$gte: initialDate,
	// 			      	$lt: finalDate
	// 			    }
	// 			}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
	// 				if(err){
	// 					res.json({success:false,error:err});
	// 				}
	// 				res.json({success: true , tickets:Tickets});
	// 			});
	// 		}
	//
	// 	}else{
	//
	// 		UserModel.findById(req.params.user_id, function(err, Usuario){
	// 			if(err){
	// 				res.json({success:false,error:err});
	// 			}
	//
	// 			var Return = [];
	// 			var Tasks = [];
	//
	// 			Usuario.lavado_id.forEach(function(carwash){
	// 				Tasks.push(function(callback){
	//
	// 					if(req.body.initialDate && req.body.finalDate){
	//
	// 						TicketModel.find(
	// 						{
	// 							lavado_id: carwash,
	// 							date: {
	// 						      	$gte: moment(req.body.initialDate),
	// 						      	$lt: moment(req.body.finalDate)
	// 						    }
	// 						}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
	// 							if(err){
	// 								res.json({success:false,error:err});
	// 							}
	// 							callback(null,Tickets);
	// 						});
	//
	// 					}else{
	//
	// 						var initialDate = moment().format('YYYY-MM-DD');
	// 						var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
	//
	// 						TicketModel.find(
	// 						{
	// 							lavado_id: carwash,
	// 							date: {
	// 						      	$gte: initialDate,
	// 						      	$lt: finalDate
	// 						    }
	// 						}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Tickets){
	// 							if(err){
	// 								res.json({success:false,error:err});
	// 							}
	// 							callback(null,Tickets);
	// 						});
	// 					}
	//                 });
	// 	    	});
	//
	// 			async.series(Tasks, function(err, result) {
	//                     if (err){
	//                         console.log(err);
	//                     }
	// 					result.forEach(function(obj){
	// 						obj.forEach(function(objToReturn){
	// 							Return.push(objToReturn);
	// 						});
	// 					});
	// 					if(Return){
	// 			    		res.json({success: true , tickets:Return});
	// 					}else{
	// 						res.json({success: false , message:'Ocurrio algun error.'});
	// 					}
	//             });
	// 		});
	// 	}
	//
	// },


	SearchCorteById: function(req,res){
		CorteModel.findById( req.params.corte_id, function(err,Corte){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , corte:Corte});

		});
	},

	UpdateCorteById: function(req,res){
		CorteModel.findById( req.params.corte_id, function(err, Corte){
			//some error
			if(err){
				res.json({success:false,error:err});
			}

			if(req.body.lavado_id){
				Corte.lavado_id = req.body.lavado_id;
			}
			if(req.body.corte_id){
				Corte.corte_id = req.body.corte_id;
			}
			if(req.body.user){
				Corte.user = req.body.user;
			}
			if(req.body.date){
				Corte.date = req.body.date;
			}

			//Salvar el usuario actualizado en la DB.
			Corte.save(function(err){
				if(err){
					res.send(err);
				}
				res.json({success: true , message:"Corte Actualizado Exitosamente."});
			});
		});

	},

	DeleteCorteById: function(req,res){
		CorteModel.remove(
			{
				_id: req.params.corte_id
			},
			function(err,Corte){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Corte Borrado Exitosamente."});
			}
		);
	},
}
