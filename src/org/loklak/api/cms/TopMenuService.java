package org.loklak.api.cms;

import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;
import org.loklak.data.DAO;
import org.loklak.server.APIHandler;
import org.loklak.server.AbstractAPIHandler;
import org.loklak.server.Authorization;
import org.loklak.server.BaseUserRole;
import org.loklak.server.Query;
import org.loklak.tools.storage.JSONObjectWithDefault;

public class TopMenuService extends AbstractAPIHandler implements APIHandler {

	private static final long serialVersionUID = 1839868262296635665L;

	@Override
	public BaseUserRole getMinimalBaseUserRole() {
		return BaseUserRole.ANONYMOUS;
	}

	@Override
	public JSONObject getDefaultPermissions(BaseUserRole baseUserRole) {
		return null;
	}

	@Override
	public String getAPIPath() {
		return "/cms/topmenu.json";
	}

	@Override
	public JSONObject serviceImpl(Query call, HttpServletResponse response, Authorization rights,
			final JSONObjectWithDefault permissions) {

		int limited_count = (int) DAO.getConfig("download.limited.count", (long) Integer.MAX_VALUE);

		JSONObject json = new JSONObject(true);
		JSONArray topmenu = new JSONArray().put(new JSONObject().put("Home", "http://loklak.org/index.html"))
				.put(new JSONObject().put("About", "http://loklak.org/about.html"))
				.put(new JSONObject().put("Blog", "http://blog.loklak.net"))
				.put(new JSONObject().put("Architecture", "http://loklak.org/architecture.html"))
				.put(new JSONObject().put("Download", "http://loklak.org/download.html"))
				.put(new JSONObject().put("Tutorials", "http://loklak.org/tutorials.html"))
				.put(new JSONObject().put("API", "http://loklak.org/api.html"));
		if (limited_count > 0)
			topmenu.put(new JSONObject().put("Dumps", "http://loklak.org/dump.html"));
		topmenu.put(new JSONObject().put("Apps", "http://apps.loklak.org"));
		json.put("items", topmenu);

		// modify caching
		json.put("$EXPIRES", 600);
		return json;
	}
}
