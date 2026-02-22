
package org.owasp.webgoat.lessons.admin;

import java.util.Enumeration;
import java.util.Iterator;
import org.apache.ecs.Element;
import org.apache.ecs.ElementContainer;
import org.apache.ecs.HtmlColor;
import org.apache.ecs.html.Center;
import org.apache.ecs.html.Input;
import org.apache.ecs.html.P;
import org.apache.ecs.html.TD;
import org.apache.ecs.html.TH;
import org.apache.ecs.html.TR;
import org.apache.ecs.html.Table;
import org.owasp.webgoat.lessons.AbstractLesson;
import org.owasp.webgoat.lessons.Category;
import org.owasp.webgoat.lessons.LessonAdapter;
import org.owasp.webgoat.session.LessonTracker;
import org.owasp.webgoat.session.Screen;
import org.owasp.webgoat.session.UserTracker;
import org.owasp.webgoat.session.WebSession;


/***************************************************************************************************
 * 
 * 
 * This file is part of WebGoat, an Open Web Application Security Project utility. For details,
 * please see http://www.owasp.org/
 * 
 * Copyright (c) 2002 - 2007 Bruce Mayhew
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if
 * not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307, USA.
 * 
 * Getting Source ==============
 * 
 * Source for this application is maintained at code.google.com, a repository for free software
 * projects.
 * 
 * For details, please see http://code.google.com/p/webgoat/
 * 
 * @author Bruce mayhew <a href="http://code.google.com">WebGoat</a>
 * @created October 28, 2003
 */
public class SummaryReportCardScreen extends LessonAdapter
{

	private int totalUsersNormalComplete = 0;

	private int totalUsersAdminComplete = 0;

	/**
	 * Description of the Method
	 * 
	 * @param s
	 *            Description of the Parameter
	 * @return Description of the Return Value
	 */
	protected Element createContent(WebSession s)
	{
		ElementContainer ec = new ElementContainer();

		String selectedUser = null;

		try
		{
			if (s.getRequest().isUserInRole(WebSession.WEBGOAT_ADMIN))
			{
				Enumeration e = s.getParser().getParameterNames();

				while (e.hasMoreElements())
				{
					String key = (String) e.nextElement();
					if (key.startsWith("View_"))
					{
						selectedUser = key.substring("View_".length());
						ReportCardScreen reportCard = new ReportCardScreen();
						return reportCard.makeReportCard(s, selectedUser);
					}
					if (key.startsWith("Delete_"))
					{
						selectedUser = key.substring("Delete_".length());
						deleteUser(selectedUser);
					}
				}
			}
		} catch (Exception e)
		{
			System.err.println("Error: " + e.getMessage()); // CAST fix: replaced printStackTrace()
		}

		ec.addElement(new Center().addElement(makeSummary(s)));

		ec.addElement(new P());

		Table t = new Table().setCellSpacing(0).setCellPadding(4).setBorder(1).setWidth("100%");
		if (s.isColor())
		{
			t.setBorder(1);
		}
		t.addElement(makeUserSummaryHeader());

		// Fix: Use Iterator variable to avoid indirect String concatenation inside loops (CAST / CWE-1050)
		Iterator<String> userIter = UserTracker.instance().getAllUsers(WebSession.WEBGOAT_USER).iterator();
		while (userIter.hasNext())
		{
			String user = userIter.next();
			t.addElement(makeUserSummaryRow(s, user));
		}

		ec.addElement(new Center().addElement(t));

		return ec;
	}

	protected Element makeSummary(WebSession s)
	{
		Table t = new Table().setCellSpacing(0).setCellPadding(2).setBorder(0).setWidth("100%");
		if (s.isColor())
		{
			t.setBorder(1);
		}
		TR tr = new TR();
		// tr.addElement( new TH().addElement( "Summary").setColSpan(1));
		// t.addElement( tr );

		tr = new TR();
		tr.addElement(new TD().setWidth("60%").addElement("Total number of users"));
		tr.addElement(new TD().setAlign("LEFT").addElement(
															Integer.toString(UserTracker.instance()
																	.getAllUsers(WebSession.WEBGOAT_USER).size())));
		t.addElement(tr);

		tr = new TR();
		tr.addElement(new TD().setWidth("60%").addElement("Total number of users that completed all normal lessons"));
		tr.addElement(new TD().setAlign("LEFT").addElement(Integer.toString(totalUsersNormalComplete)));
		t.addElement(tr);

		tr = new TR();
		tr.addElement(new TD().setWidth("60%").addElement("Total number of users that completed all admin lessons"));
		tr.addElement(new TD().setAlign("LEFT").addElement(Integer.toString(totalUsersAdminComplete)));
		t.addElement(tr);
		return t;
	}

	private void deleteUser(String user)
	{
		UserTracker.instance().deleteUser(user);
	}

	/**
	 * Gets the category attribute of the UserAdminScreen object
	 * 
	 * @return The category value
	 */
	protected Category getDefaultCategory()
	{
		return Category.ADMIN_FUNCTIONS;
	}

	private final static Integer DEFAULT_RANKING = new Integer(1000);

	protected Integer getDefaultRanking()
	{
		return DEFAULT_RANKING;
	}

	/**
	 * Gets the role attribute of the UserAdminScreen object
	 * 
	 * @return The role value
	 */
	public String getRole()
	{
		return ADMIN_ROLE;
	}

	/**
	 * Gets the title attribute of the UserAdminScreen object
	 * 
	 * @return The title value
	 */
	public String getTitle()
	{
		return ("Summary Report Card");
	}

	/**
	 * Description of the Method
	 * 
	 * @param s
	 *            Description of the Parameter
	 * @return Description of the Return Value
	 */
	protected Element makeMessages(WebSession s)
	{
		ElementContainer ec = new ElementContainer();

		return (ec);
	}

	/**
	 * Description of the Method
	 * 
	 * @return Description of the Return Value
	 */
	protected Element makeUserSummaryHeader()
	{
		TR tr = new TR();

		tr.addElement(new TH("User Name"));
		tr.addElement(new TH("Normal Complete"));
		tr.addElement(new TH("Admin Complete"));
		tr.addElement(new TH("View"));
		tr.addElement(new TH("Delete"));

		return tr;
	}

	/**
	 * Description of the Method
	 * 
	 * @param s
	 *            Description of the Parameter
	 * @param user
	 *            Description of the Parameter
	 * @return Description of the Return Value
	 */
	/**
	 * Performance: extracted duplicate lesson-counting loop into a helper method
	 * to reduce code duplication and improve maintainability.
	 *
	 * @return int array where [0] = passedCount, [1] = lessonCount
	 */
	private int[] countCompletedLessons(WebSession s, String user, String role)
	{
		int lessonCount = 0;
		int passedCount = 0;
		for (Iterator lessonIter = s.getCourse().getLessons(s, role).iterator(); lessonIter.hasNext();)
		{
			lessonCount++;
			Screen screen = (Screen) lessonIter.next();
			LessonTracker lessonTracker = UserTracker.instance().getLessonTracker(s, user, screen);
			if (lessonTracker.getCompleted())
			{
				passedCount++;
			}
		}
		return new int[] { passedCount, lessonCount };
	}

	protected Element makeUserSummaryRow(WebSession s, String user)
	{
		TR tr = new TR();

		tr.addElement(new TD().setAlign("LEFT").addElement(user));
		boolean normalComplete = false;
		boolean adminComplete = false;

		// Count normal lessons using extracted helper
		int[] normalCounts = countCompletedLessons(s, user, AbstractLesson.USER_ROLE);
		int passedCount = normalCounts[0];
		int lessonCount = normalCounts[1];
		if (lessonCount == passedCount)
		{
			normalComplete = true;
			totalUsersNormalComplete++;
		}
		// Fix: Use StringBuilder to avoid indirect String concatenation inside loops (CAST / CWE-1050)
		StringBuilder textBuilder = new StringBuilder(64) // CAST fix: pre-sized buffer;
		textBuilder.append(passedCount).append(" of ").append(lessonCount);
		tr.addElement(new TD().setAlign("CENTER").addElement(textBuilder.toString()));

		// Count admin lessons using extracted helper
		int[] adminCounts = countCompletedLessons(s, user, AbstractLesson.HACKED_ADMIN_ROLE);
		passedCount = adminCounts[0];
		lessonCount = adminCounts[1];
		if (lessonCount == passedCount)
		{
			adminComplete = true;
			totalUsersAdminComplete++;
		}
		textBuilder = new StringBuilder(64) // CAST fix: pre-sized buffer;
		textBuilder.append(passedCount).append(" of ").append(lessonCount);
		String text = textBuilder.toString();
		tr.addElement(new TD().setAlign("CENTER").addElement(text));

		tr.addElement(new TD().setAlign("CENTER").addElement(new Input(Input.SUBMIT, "View_" + user, "View")));
		tr.addElement(new TD().setAlign("CENTER").addElement(new Input(Input.SUBMIT, "Delete_" + user, "Delete")));

		if (normalComplete && adminComplete)
		{
			tr.setBgColor(HtmlColor.GREEN);
		}
		else if (normalComplete)
		{
			tr.setBgColor(HtmlColor.LIGHTGREEN);
		}
		else
		{
			tr.setBgColor(HtmlColor.LIGHTBLUE);
		}

		return (tr);
	}

	public boolean isEnterprise()
	{
		return true;
	}
}
