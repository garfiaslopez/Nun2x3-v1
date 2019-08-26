//MODELS
var PaybillModel = require("../models/paybill");

var mongoose = require("mongoose");
var moment = require("moment");

var Schema = mongoose.Schema;
var ObjectId = mongoose.Types.ObjectId;


module.exports = {

	AddNewPaybill: function(req,res){

		var TokenObj = req.decoded;
		var Paybill = new PaybillModel();

		//se rellenan los campos
		Paybill.lavado_id = req.body.lavado_id;
		Paybill.corte_id = req.body.corte_id;
		Paybill.denomination = req.body.denomination;
		Paybill.total = req.body.total;

		//se asigna el usuario del token
		Paybill.user = TokenObj.user_username;
		Paybill.owner = req.body.owner;
		Paybill.date = req.body.date;

		Paybill.save(function(err){

			if(err){
				return res.json({success:false,error:err});
			}

			res.json({success: true , message:"Vale Agregado Exitosamente.", _id: Paybill._id});
		});
	},

	AllPaybills: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			PaybillModel.find( function(err, Paybills) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , paybills:Paybills});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}



	},

	AllPaybillsByLavado: function(req,res) {
		var Query;
		var lavado_id = new ObjectId(req.params.lavado_id);
		var Paginator = {
			page: 1,
			limit: 10
		};
		if (req.body.page){
			Paginator.page = req.body.page;
		}
		if (req.body.limit) {
			Paginator.limit = req.body.limit;
		}
		if(req.body.initialDate && req.body.finalDate){
			var initialDate = moment(req.body.initialDate).toDate();
			var finalDate = moment(req.body.finalDate).toDate();

			if(req.body.corte_id){
				Query = {
					lavado_id: lavado_id,
					corte_id: String(req.body.corte_id),
					date: {
						$gt: initialDate,
						$lt: finalDate
					}
				};
			}else{
				Query = {
					lavado_id: lavado_id,
					date: {
						$gt: initialDate,
						$lt: finalDate
					}
				};
			}
		}else if(req.body.corte_id){
			Query = {
				lavado_id: lavado_id,
				corte_id: String(req.body.corte_id)
			};
		}else{
			var initialDate = moment().format('YYYY-MM-DD');
			var finalDate = moment().add(1,'day').format('YYYY-MM-DD');
			Query = {
				lavado_id: lavado_id,
				date: {
					$gt: initialDate,
					$lt: finalDate
				}
			};
		}
		PaybillModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , paybills: result});
		});
	},


	AllPaybillsByAccount: function(req,res) {

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			if(req.body.initialDate && req.body.finalDate){

				PaybillModel.find(
				{
					date: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Paybills){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , paybills:Paybills});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

				PaybillModel.find(
				{
					date: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Paybills){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , paybills:Paybills});
				});
			}

		}else{

			PaybillModel.findById(req.params.user_id, function(err, Usuario){
				if(err){
					res.json({success:false,error:err});
				}

				var Return = [];
				var Tasks = [];

				Usuario.lavado_id.forEach(function(carwash){
					Tasks.push(function(callback){

						if(req.body.initialDate && req.body.finalDate){

							PaybillModel.find(
							{
								date: {
							      	$gte: moment(req.body.initialDate),
							      	$lt: moment(req.body.finalDate)
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Paybills){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Paybills);
							});
						}else{
							var initialDate = moment().format('YYYY-MM-DD');
							var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

							PaybillModel.find(
							{
								date: {
							      	$gte: initialDate,
							      	$lt: finalDate
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Paybills){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Paybills);
							});
						}
	                });
		    	});

				async.series(Tasks, function(err, result) {
	                    if (err){
	                        console.log(err);
	                    }
						result.forEach(function(obj){
							obj.forEach(function(objToReturn){
								Return.push(objToReturn);
							});
						});
						if(Return){
				    		res.json({success: true , paybills:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}
	},


	SearchPaybillById: function(req,res){

		PaybillModel.findById( req.params.paybill_id, function(err,Paybill){
			if(err){
				res.json({success:false,error:err});
			}

			res.json({success: true , paybill:Paybill});

		});
	},



	UpdatePaybillById: function(req,res){

		PaybillModel.findById( req.params.paybill_id, function(err, Paybill){
			//some error
			if(err){
				res.json({success:false,error:err});
			}
			//se rellenan los campos
			if(req.body.denomination){
				Paybill.denomination = req.body.denomination;
			}
			if(req.body.total){
				Paybill.total = req.body.total;
			}
			if(req.body.owner){
				Paybill.owner = req.body.owner;
			}

			//Salvar el usuario actualizado en la DB.
			Paybill.save(function(err){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Vale Actualizado Exitosamente."});
			});
		});

	},

	DeletePaybillById: function(req,res){

		PaybillModel.remove(
			{
				_id: req.params.paybill_id
			},
			function(err,Paybill){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Vale Borrado Exitosamente."});
			}
		);
	},

}
