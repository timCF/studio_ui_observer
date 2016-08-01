jf = require('jsfunky')
module.exports =
	error: (mess) -> toastr.error(mess)
	warn: (mess) -> toastr.warning(mess)
	notice: (mess) -> toastr.success(mess)
	info: (mess) -> toastr.info(mess)
	view_set: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.value?)
			subj = ev.target.value
			jf.put_in(state, path, subj)
	view_put: (state, path, data) ->
		jf.put_in(state, path, data)
	view_swap: (state, path) ->
		jf.update_in(state, path, (bool) -> not(bool))
	view_files: (state, path, ev) ->
		if (ev? and ev.target? and ev.target.files? and (ev.target.files.length > 0))
			jf.update_in(state, path, (_) -> [].map.call(ev.target.files, (el) -> el))
			console.log(jf.get_in(state, path))
	auth: (state) ->
		state.auth = true
	jf: jf
	multiple_select: (state, path, ev) ->
		if (ev? and ev.target?)
			jf.put_in(state, path, [].slice.call(ev.target.options).filter((el) -> el.selected).map((el) -> el.value))
	set_location: (state, ev) ->
		utils = @
		if (ev? and ev.target? and ev.target.value?)
			subj = ev.target.value
			state.ids.location = false
			state.ids.room = false
			await utils.render(defer dummy)
			jf.update_in(state, ["ids","location"], (_) -> (if subj == "" then false else subj))
	set_room: (state, path, ev) ->
		utils = @
		if (ev? and ev.target? and ev.target.value?)
			subj = ev.target.value
			jf.update_in(state, path, (_) -> (if subj == "" then false else subj))
	maybedate2moment: (some) ->
		if some then moment(some) else null
	new_datepairval: (state) ->
		utils = @
		console.log("new datepairval")
		state.datepairval.date.start = utils.maybedate2moment($('#datepair .date.start').datepicker('getDate'))
		state.datepairval.date.end = utils.maybedate2moment($('#datepair .date.end').datepicker('getDate'))
		state.datepairval.time.start = utils.maybedate2moment($('#datepair .time.start').timepicker('getTime'))
		state.datepairval.time.end = utils.maybedate2moment($('#datepair .time.end').timepicker('getTime'))
	get_hours_list: (moment) ->
		[9..24].map((el) -> moment.clone().hour(el))
	get_days_list: (sessions, state) ->
		utils = @
		switch sessions.length
			when 0 then []
			else
				{max: max, min: min} = jf.reduce(sessions, {max: sessions[0].time_from, min: sessions[0].time_from}, (el, acc) ->
					if (el.time_from.compare(acc.min) == -1) then acc.min = el.time_from
					if (el.time_from.compare(acc.max) == 1) then acc.max = el.time_from
					acc)
				utils.get_moments_range((if state.datepairval.date.start then state.datepairval.date.start else moment(min * 1000)), (if state.datepairval.date.end then state.datepairval.date.end else moment(max * 1000)), [])
	moment2wd: (moment) ->
		wd = moment.day()
		if (wd == 0) then "WD_7" else ("WD_"+wd)
	get_moments_range: (min_o, max_o, acc) ->
		utils = @
		min = min_o.clone()
		max = max_o.clone()
		pd = "YYYY-MM-DD"
		if (min.format(pd) == max.format(pd))
			acc.concat([min])
		else
			utils.get_moments_range(min.clone().add(1,'d'), max, acc.concat([min]))
	get_locations: (state) ->
		if state.ids.location then state.response_state.locations.filter((el) -> el.id.compare(state.ids.location) == 0) else state.response_state.locations
	get_rooms: (state, location) ->
		(if state.ids.room then state.response_state.rooms.filter((el) -> el.id.compare(state.ids.room) == 0) else state.response_state.rooms).filter((el) -> el.location_id.compare(location.id) == 0)
