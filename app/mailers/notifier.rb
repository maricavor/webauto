
class Notifier < ActionMailer::Base
  default from: "info@webauto.ee"
  #layout 'notifier'

  add_template_helper(ApplicationHelper)
  def comment_updated(comment, user)
    @comment = comment
    @user= user
    mail(to: user.email, subject: "[webauto] #{comment.vehicle.make_model}")
  end
  def vehicle_price_updated(vehicle,user)
    @vehicle = vehicle
    @user= user
    mail(to: user.email, subject: "[webauto] #{vehicle.make_model}")
  end
  def vehicle_status_sold(advert,user)
    @advert = advert
    @user= user
    mail(to: user.email, subject: "[webauto] #{advert.vehicle.make_model}")
  end
  def adverts_created(search_alert)
    @search_alert=search_alert
    @search=search_alert.search
    @results=search_alert.results.split(',')
    @user=search_alert.user
    mail(to: @user.email,subject: "Latest cars that match your saved search")
  end
def contact_user_submitted(inquiry,user)
    @user=user
    @inquiry=inquiry
    #mail(to: @user.email,from: %("#{inquiry.name}" <#{inquiry.email}>), reply_to: inquiry.email, subject: "User inquiry")
  end
  def inquiry_submitted(inquiry,vehicle)
    @vehicle=vehicle
    @inquiry=inquiry
    #mail(to: @vehicle.user.email,from: %("#{inquiry.name}" <#{inquiry.email}>), reply_to: inquiry.email, subject: "Vehicle inquiry")
  end

def send_to_friend_submitted(inquiry,vehicle)
                                           @vehicle=vehicle
                                           @inquiry=inquiry
                                           mail(to: inquiry.friend_email, reply_to: %("#{inquiry.name}" <#{inquiry.email}>), subject: inquiry.name+" thought you might be interested in this vehicle")
                                                                                      end
  def report_submitted(inquiry,vehicle)
                                                                                        @vehicle=vehicle
                                                                                        @inquiry=inquiry
                                                                                        #mail(to: inquiry.email, subject: "Report Ad")
                                                                                      end

  end