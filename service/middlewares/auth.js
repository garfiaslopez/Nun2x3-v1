//JSONWEBTOKEN
var jwt = require("jsonwebtoken");

//Config File
var Config = require("./../config/config");
var KeyToken = Config.key;
var configLang = require('../config/system/langs');
var Log = require('../config/system/winston');

var LavadoModel = require("../models/carwash");
var UserModel = require("../models/user");
var mongoose = require("mongoose");

module.exports = {

	isAuthenticated: function(req,res,next){

		//Detect language
	    var lang = (typeof configLang.langs[req.headers['accept-language']] == 'undefined' ) ? 'es' : req.headers['accept-language'];

	    if (!(req.headers && req.headers.authorization)) {

	        res.json(403, configLang.langs[lang]['AUTH_AUTHENTICATION_EMPTY_HEADERS']);
	    }

		var token = req.headers.authorization;

		if(token){

			jwt.verify(token,Config.key,{ignoreExpiration:true},function(err,decoded){

				if(err){
					return res.send({success:false,message:"Corrupt Token."});
				}else{

					req.decoded = decoded;
					next();
				}
			});
		}else{

			return res.send({success:false,message:"No token provided."});

		}

	}


};
