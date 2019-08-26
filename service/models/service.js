
var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var ServiciosSchema = new Schema({

	lavado_id: { 
		type: Schema.ObjectId, 
		ref: 'Carwash',
		required: true
	},
	denomination:{
		type: String, 
		default: "Sin Descripcion",
		required: true
	},
	price:{
		type: Number,
		default: 0.00
	},
	img:{
		type: String,
		default: "../src/images/defaultservice.jpg"
	},
    created: {
        type: Date,
        default: Date.now()
    }

});

//Return the module
module.exports = mongoose.model("Service",ServiciosSchema);