//MODELS
var StockModel = require("../models/stock");
var UserModel = require("../models/user");

var mongoose = require("mongoose");
var moment = require("moment");
var async = require("async");

var Schema = mongoose.Schema;


module.exports = {

	AddNewStock: function(req,res){

		var TokenObj = req.decoded;
		req.body.lavado_id.forEach(function(carwash){

			var Stock = new StockModel();

			Stock.lavado_id = carwash;
			Stock.product.denomination = req.body.product.denomination;
			Stock.product.quantity = Number(req.body.product.quantity);
			Stock.product.price = Number(req.body.product.price);
			Stock.total = Stock.product.quantity * Stock.product.price;
			Stock.deliverDate = req.body.deliverDate;

			Stock.save(function(err){
				if(err){
					return res.json({success:false,error:err});
				}
				res.json({success: true , message:"Stock Agregado Exitosamente."});
			});
		});
	},

	AllStocks: function(req,res){

		var TokenObj = req.decoded;
		if (TokenObj.rol == "SuperAdministrador") {

			StockModel.find( function(err, Stocks) {

				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , stocks:Stocks});
			});

		}else{
			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}



	},

	AllStocksByLavado: function(req,res) {

		if(req.body.initialDate && req.body.finalDate){
			StockModel.find(
				{
					lavado_id: req.params.lavado_id,
					deliverDate: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , stocks:Stocks});
				});

		}else{

			var initialDate = moment().format('YYYY-MM-DD');
			var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

			StockModel.find(
			{
				lavado_id: req.params.lavado_id,
				deliverDate: {
			      	$gte: initialDate,
			      	$lt: finalDate
			    }
			}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , stocks:Stocks});
			});
		}
	},


	AllStocksByAccount: function(req,res) {
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			if(req.body.initialDate && req.body.finalDate){

				StockModel.find(
				{
					deliverDate: {
				      	$gte: moment(req.body.initialDate),
				      	$lt: moment(req.body.finalDate)
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , stocks:Stocks});
				});
			}else{
				var initialDate = moment().format('YYYY-MM-DD');
				var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

				StockModel.find(
				{
					deliverDate: {
				      	$gte: initialDate,
				      	$lt: finalDate
				    }
				}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , stocks:Stocks});
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

							StockModel.find(
							{
								lavado_id: carwash,
								deliverDate: {
							      	$gte: moment(req.body.initialDate),
							      	$lt: moment(req.body.finalDate)
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Stocks);
							});

						}else{

							var initialDate = moment().format('YYYY-MM-DD');
							var finalDate = moment().add(1,'day').format('YYYY-MM-DD');

							SpendModel.find(
							{
								lavado_id: carwash,
								deliverDate: {
							      	$gte: initialDate,
							      	$lt: finalDate
							    }
							}).populate({path: 'lavado_id', select: 'info.name'}).exec(function(err,Stocks){
								if(err){
									res.json({success:false,error:err});
								}
								callback(null,Stocks);
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
				    		res.json({success: true , stocks:Return});
						}else{
							res.json({success: false , message:'Ocurrio algun error.'});
						}
	            });
			});
		}

	},


	SearchStockById: function(req,res){

		StockModel.findById( req.params.stock_id, function(err,Stock){
			if(err){
				res.json({success:false,error:err});
			}

			res.json({success: true , stock:Stock});

		});
	},



	UpdateStockById: function(req,res){

		StockModel.findById(req.params.stock_id, function(err, Stock){
			//some error
			if(err){
				res.json({success:false,error:err});
			}

			if(req.body.lavado_id){
				Stock.lavado_id = req.body.lavado_id;
			}
			if(req.body.product){
				Stock.product.denomination = req.body.product.denomination;
				Stock.product.quantity = Number(req.body.product.quantity);
				Stock.product.price = Number(req.body.product.price);
				Stock.total = Stock.product.quantity * Stock.product.price;
			}
			if(req.body.deliverDate){
				Stock.deliverDate = req.body.deliverDate;
			}

			Stock.save(function(err){
				if(err){
					return res.json({success:false,error:err});
				}
				res.json({success: true , message:"Stock Agregado Exitosamente."});
			});

		});

	},

	DeleteStockById: function(req,res){

		StockModel.remove(
			{
				_id: req.params.stock_id
			},
			function(err,Stock){
				if(err){
					res.json({success:false,error:err});
				}
				res.json({success: true , message:"Stock Borrado Exitosamente."});
			}
		);
	},

}
