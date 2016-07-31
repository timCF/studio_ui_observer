module.exports = (state, utils) ->
	# request template
	req = new utils.proto.Request
	req.cmd = 'CMD_get_state'
	req.client_kind = 'CK_observer'
	req.login = ''
	req.password = ''
	req.subject = new utils.proto.FullState
	req.subject.hash = ''
	state.request_template = req
