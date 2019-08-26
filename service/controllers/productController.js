//MODELS
var ProductModel = require("../models/product");

module.exports = {

	AddNewProduct: function(req,res){
		
		var TokenObj = req.decoded;
		var Product = new ProductModel();

		if (TokenObj.rol == "SuperAdministrador") {

			Product.denomination = req.body.denomination;
			Product.price = req.body.price;
			//IMG PENDING.
			

			Product.save(function(err){

				if(err){
					//entrada duplicada
					if(err.code == 11000){
						return res.json({success: false , message: "Ya existe un Producto con ese nombre."});
					}else{
						return res.json({success:false,error:err});
					}
				}

				res.json({success: true , message:"producto Agregado Existosamente."});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	AllProducts: function(req,res){

		ProductModel.find( function(err, Products) {

			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , products:Products});
		});
	},

	SearchProductById: function(req,res){

		ProductModel.findById( req.params.product_id, function(err,Product){
			if(err){
				res.json({success:false,error:err});
			}
			res.json({success: true , product:Product});
		});
	},

	UpdateProductById: function(req,res){

		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			ProductModel.findById( req.params.product_id, function(err, Product){
				//some error
				if(err){
					res.json({success:false,error:err});
				}

				//Getting the values from the body request and putting on the user recover from mongo
				if(req.body.denomination){
					Product.denomination = req.body.denomination;
				}
				if (req.body.price){
					Product.price = req.body.price;
				}
				//IMG PENDING

				//Salvar el usuario actualizado en la DB.
				Product.save(function(err){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Datos De Producto Actualizado"});
				});
			});

		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}

	},


	DeleteProductById: function(req,res){
		var TokenObj = req.decoded;

		if (TokenObj.rol == "SuperAdministrador") {

			ProductModel.remove(
				{
					_id: req.params.product_id
				},
				function(err,Product){
					if(err){
						res.json({success:false,error:err});
					}
					res.json({success: true , message:"Producto Borrado Satisfactoriamente"});
				}
			);
		}else{

			res.json({success:false,message:"No tienes los permisos para esta operacion."});
		}
	},


}