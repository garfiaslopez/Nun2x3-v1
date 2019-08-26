var mongoose = require("mongoose");
var mongoosePaginate = require('mongoose-paginate');

var Schema = mongoose.Schema;


//DATE y CREATED SE GUARDA EN FORMATO ISO.
var SpendSchema = new Schema({

	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
	corte_id:{
		type: String
	},
	denomination: {
		type: String,
		trim: true,
		required: true,
	},
	total: {
		type: Number,
		required: true,
		default: 0.00
	},
	user: {
		type: String
	},
	date: {
		type: Date,
		required: true
	},
    created: {
        type: Date,
        default: Date.now
    },
	isMonthly:{
		type: Boolean,
		default: false
	}

});
SpendSchema.plugin(mongoosePaginate);

//Return the module
module.exports = mongoose.model("Spend",SpendSchema);
