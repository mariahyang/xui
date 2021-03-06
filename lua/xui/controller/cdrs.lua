--[[
/*
 * HTML5 GUI Framework for FreeSWITCH - XUI
 * Copyright (C) 2015-2016, Seven Du <dujinfang@x-y-t.cn>
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is XUI - GUI for FreeSWITCH
 *
 * The Initial Developer of the Original Code is
 * Seven Du <dujinfang@x-y-t.cn>
 * Portions created by the Initial Developer are Copyright (C)
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Seven Du <dujinfang@x-y-t.cn>
 *
 *
 */
]]

require 'xdb'
xdb.bind(xtra.dbh)

get('/', function(params)
	id = env:getHeader('id')

	if id == '0' or id == '1' then
		last = env:getHeader('last')
		if not last then last = "31" end

		n, cdrs = xdb.find_by_time("cdrs", last)

		if (n > 0) then
			return cdrs
		else
			return "[]"
		end
	end

	if id == '2' then
		startDate = env:getHeader('startDate')
		endDate = env:getHeader('endDate')
		cidNumber = env:getHeader('cidNumber')
		destNumber = env:getHeader('destNumber')
		n, cdrs = xdb.find_by_time_by_calender("cdrs", startDate, endDate, cidNumber, destNumber)

		if (n > 0) then
			return cdrs
		else
			return "[]"
		end
	end

end)
