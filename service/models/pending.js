var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var PendingSchema = new Schema({
	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
    denomination: {
		type: String,
		trim: true,
		required: true,
	},
	user: {
		type: String
	},
    isDone: {
        type: Boolean,
        default: false
    },
	corte_id:{
		type: String
	},
	date: {
		type: Date
	},
	created: {
		type: Date,
		default: Date.now
	}
});

//Return the module
module.exports = mongoose.model("Pending",PendingSchema);
