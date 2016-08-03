document.addEventListener "DOMContentLoaded", (e) ->
	jf = require('jsfunky')
	timepicker_opts = {
		minTime: "9:00",
		maxTime: "23:00",
		timeFormat: 'H:i',
		disableTextInput: true,
		disableTouchKeyboard: true,
		show2400: true,
		step: 60
	}
	datepicker_opts = {
		format: 'dd/mm/yyyy',
		autoclose: true,
		daysOfWeekHighlighted: '06',
		disableTouchKeyboard: true,
		todayBtn: true,
		todayHighlight: true,
		weekStart: 1,
	}
	prettyform = (e) ->
		keyCode = e.keyCode || e.which
		if ( keyCode ==  13 )
			e.preventDefault()
			nextElement = $('[tabindex="' + (this.tabIndex+1)  + '"]')
			if(nextElement.length != 0)
				nextElement.focus()
			else
				$('[tabindex="1"]').focus()
				$('.submitmegaform')[0].click()
	$(document).on("keypress",".megaform", prettyform)
	react = require("react-dom")
	widget = require("widget")
	render_tooltips = () ->
		$('[data-toggle="tooltip"]').tooltip()
		out = $(".tooltip").attr('id')
		if out and ($("[aria-describedby='"+out+"']").length == 0)
			$( document.getElementById(out) ).remove()
			console.log("destroy tooltip "+out)
	render_jqcb = () ->
		# NOTICE !!! not reload page on submit forms
		$('form').submit((e) -> e.preventDefault())
	render_datepair = () ->
		datepair = document.getElementById('datepair')
		if not(datepair) then (state.datepair = false)
		if not(state.datepair) and datepair
			$('#datepair .time').timepicker(timepicker_opts)
			$('#datepair .date').datepicker(datepicker_opts)
			state.datepair = new Datepair(datepair, {defaultTimeDelta: 10800000, defaultDateDelta: 32})
			$('#datepair').on('rangeSelected', () -> utils.new_datepairval(state))
			$('#datepair').on('rangeError', () -> utils.new_datepairval(state))
			$('#datepair').on('rangeIncomplete', () -> utils.new_datepairval(state))
			console.log("render datepair")
			await utils.render(defer dummy)
			$('#datepair .date.start').datepicker('setDate', (new Date()))
			dummy
	render = (cb) ->
		render_datepair()
		render_tooltips()
		render_jqcb()
		$('.selectpicker').selectpicker({noneSelectedText: "ничего не выбрано"})
		await react.render(widget(fullstate), document.getElementById("main_frame"), defer dummy)
		if jf.is_function(cb,1) then cb(state)
		dummy
	render_coroutine = () ->
		await render(defer dummy)
		setTimeout(render_coroutine, 500)
		dummy
	#
	# state for main function, mutable
	#
	# state for main function, mutable
	state = {
		callbacks: {
			msg: false,
			close_popup: false,
		},
		# this is custom callback, function (message, state)
		# called on new message from server for dynamic smart popups
		dicts: {},
		rooms_of_locations: {}, # just dict room_id => location_id
		request_template: false,
		response_state: false,
		datepair: false,
		datepairval: {
			date: {start: '', end: ''},
			time: {start: '', end: ''}
		},
		ids: {
			location: false,
			room: false,
			week_days: []
		},
		verbose: require("verbose")
	}
	#
	# state for main function, mutable
	#
	utils = Object.freeze(tmp = require("bullet")(require("proto")(require("utils")), state) ; tmp.render = render ; tmp.render_coroutine = render_coroutine ; tmp)
	fullstate = Object.freeze({state: state, utils: utils})
	require("main")(state, utils)
