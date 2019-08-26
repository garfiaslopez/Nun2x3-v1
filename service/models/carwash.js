//PACKAGES:

var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");


var LavadoSchema = new Schema({

	info:{
		name: {type: String, default: "Sin Nombre"},
		phone: {type: String, default: "Sin Numero Telefonico"},
		address: {type: String, default: "Sin Direccion"},
        type: {type: String, default: "1"}
	},
    created: {
        type: Date,
        default: Date.now()
    },
    status: {
    	type: Boolean,
    	default: true
    },
    users: [{
        type: Schema.ObjectId,
        ref: 'User'
    }]

});


//Return the module
module.exports = mongoose.model("Carwash",LavadoSchema);
