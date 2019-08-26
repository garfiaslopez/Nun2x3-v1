var mongoose = require("mongoose");
var mongoosePaginate = require('mongoose-paginate');

var Schema = mongoose.Schema;

var PaybillSchema = new Schema({

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
	date:{
		type: Date
	},
    created: {
        type: Date,
        default: Date.now
    },
	owner:{
		type: String,
		trim: true
	}

});
PaybillSchema.plugin(mongoosePaginate);

//Return the module
module.exports = mongoose.model("Paybill",PaybillSchema);
