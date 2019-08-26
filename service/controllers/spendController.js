//MODELS
var SpendModel = require("../models/spend");
var UserModel = require("../models/user");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;
var ObjectId = mongoose.Types.ObjectId;


module.exports = {

	AddNewSpend: function(req,res){

		var TokenObj = req.decoded;
		var Spend = new SpendModel();

		//se rellenan los campos
		Spend.lavado_id = req.body.lavado_id;
		Spend.corte_id = req.body.corte_id;
		Spend.denomination = req.body.denomination;
		Spend.total = req.body.total;
		if(req.body.isMonthly){
			Spend.isMonthly = req.body.isMonthly;
		}

		//se asigna el usuario del token
		Spend.user = TokenObj.user_username;
		Spend.date = req.body.date;
		console.log(Spend);

		Spend.save(function(err){

			if(err){
				return res.json({success:false,error:err});
			}

			res.json({success: true , message:"Gasto Agregado Exitosamente.", _id: Spend._id});
		});
	},

	AllSpends: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			SpendModel.find( function(err, Spends) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , spends:Spends});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}



	},

	AllSpendsByLavado: function(req,res) {
		var Query;
		var lavado_id = new ObjectId(req.params.lavado_id);
		var Paginator = {
			page: 1,
			limit: 100
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
		SpendModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , spends: result});
		});
	},


	AllSpendsByAccount: function(req,res) {

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			if(req.body.initialDate && req.body.finalDate){

				SpendModel.find(
				{
					date: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Spends){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , spends:Spends});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

				SpendModel.find(
				{
					date: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Spends){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , spends:Spends});
				});
			}

		}else{

			UserModel.findById(req.params.user_id, function(err, Usuario){
				if(err){
					res.json({success:false,error:err});
				}

				var Return = [];
				var Tasks = [];

				Usuario.lavado_id.forEach(function(carwash){
					Tasks.push(function(callback){

						if(req.body.initialDate && req.body.finalDate){

							SpendModel.find(
							{
								lavado_id: carwash,
								date: {
							      	$gte: moment(req.body.initialDate),
							      	$lt: moment(req.body.finalDate)
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Spends){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Spends);
							});

						}else{

							var initialDate = moment().format('YYYY-MM-DD');
							var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

							SpendModel.find(
							{
								lavado_id: carwash,
								date: {
							      	$gte: initialDate,
							      	$lt: finalDate
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Spends){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Spends);
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
				    		res.json({success: true , spends:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}

	},


	SearchSpendById: function(req,res){
		SpendModel.findById( req.params.spend_id, function(err,Spend){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , spend:Spend});
		});
	},



	UpdateSpendById: function(req,res){

		SpendModel.findById( req.params.spend_id, function(err, Spend){
			//some error
			if(err){
				res.json({success:false,error:err});
			}
			//se rellenan los campos
			if(req.body.denomination){
				Spend.denomination = req.body.denomination;
			}
			if(req.body.corte_id){
				Spend.corte_id = req.body.corte_id;
			}
			if(req.body.total){
				Spend.total = req.body.total;
			}
			if(req.body.isMonthly){
				Spend.isMonthly = req.body.isMonthly;
			}
			//Salvar el usuario actualizado en la DB.
			Spend.save(function(err){
				if(err){
					res.send(err);
				}
				res.json({success: true , message:"Gasto Actualizado Exitosamente."});
			});
		});

	},

	DeleteSpendById: function(req,res){
		SpendModel.remove(
			{
				_id: req.params.spend_id
			},
			function(err,Spend){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Gasto Borrado Exitosamente."});
			}
		);
	},

	DeleteSpendsById: function(req,res){
		var Tasks = [];
		req.body.spends.forEach(function(spend_id){
			Tasks.push(function(callback){
				SpendModel.remove(
					{
						_id: spend_id
					},
					function(err,Spend){
						if(err){
							res.json({success:false,error:err});
						}
						callback(null,Spend);
					}
				);
			});
		});

		async.series(Tasks, function(err, result) {
				if (err){
					console.log(err);
				}
				if(result){
					res.json({success: true , message: 'Gastos Borrados.'});
				}else{
					res.json({success: false , message:'Ocurrio algun error.'});
				}
		});
	},
}
