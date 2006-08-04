

class Admin::FeedbackController < Admin::BaseController
  model :comment, :trackback

  def index
    conditions = ['1=1', {}]

    if params[:search]
      conditions.first << ' and (url like :pattern or author like :pattern or title like :pattern or ip like :pattern or email like :pattern)'
      conditions.last.merge!(:pattern => "%#{params[:search]}%")
    end

    if params[:published] == 'f'
      conditions.first << ' and (published = :published)'
      conditions.last.merge!(:published => false)
    end

    @pages, @feedback = paginate(:feedback,
      :order => 'contents.created_at desc',
      :conditions => conditions,
      :per_page => 40)

    render_action 'list'
  end

  def delete
    if request.post?
      begin
        Feedback.destroy(params[:id])
        flash[:notice] = "Deleted"
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Not found"
      end
    end
    redirect_to :action => 'index', :page => params[:page], :search => params[:search]
  end

  def bulkops
    STDERR.puts "Bulkops: #{params.inspect}"

    ids = (params[:feedback_check]||{}).keys.map(&:to_i)

    case params[:commit]
    when 'Delete Checked Items'
      count = 0
      ids.each do |id|
        count += Feedback.delete(id) ## XXX Should this be #destroy?
      end
      flash[:notice] = "Deleted #{count} item(s)"
    when 'Mark Checked Items as Ham'
      ids.each do |id|
        feedback = Feedback.find(id)
        feedback.mark_as_ham!
      end
      flash[:notice]= "Marked #{ids.size} item(s) as Ham"
    when 'Mark Checked Items as Spam'
      ids.each do |id|
        feedback = Feedback.find(id)
        feedback.mark_as_spam!
      end
      flash[:notice]= "Marked #{ids.size} item(s) as Spam"
    when 'Confirm Classification of Checked Items'
      ids.each do |id|
        Feedback.find(id).confirm_classification!
      end
      flash[:notice] = "Confirmed classification of #{ids.size} item(s)"
    else
      flash[:notice] = "Not implemented"
    end

    redirect_to :action => 'index', :page => params[:page], :search => params[:search]
  end
end