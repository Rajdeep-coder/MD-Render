module Fittonia
  class CandidateMailer < Fittonia::FittoniaBaseMailer
    def new_application_notification(candidate)
      @candidate = candidate
      attach_resume if @candidate.resume.attached?
      mail(to: 'hr@ftpls.com', subject: 'New Candidate Application - Fittonia Technologies')
    end

    def application_received_email(candidate)
      @candidate = candidate
      attach_resume if @candidate.resume.attached?
      mail(to: @candidate.email, subject: 'Application Received - Fittonia Technologies')
    end

    def shortlisted_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Shortlisted - Fittonia Technologies')
    end

    def written_exam_cleared_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Written Exam Cleared - Fittonia Technologies')
    end

    def technical_interview_passed_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Technical Interview Passed - Fittonia Technologies')
    end

    def hr_interview_cleared_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'HR Interview Cleared - Fittonia Technologies')
    end

    def on_hold_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Application On Hold - Fittonia Technologies')
    end

    def hiring_closed_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Hiring Closed - Fittonia Technologies')
    end

    def not_selected_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Application Not Selected - Fittonia Technologies')
    end

    def hiring_open_email(candidate)
      @candidate = candidate
      mail(to: @candidate.email, subject: 'Hiring is Open - Fittonia Technologies')
    end

    def attach_resume
      resume_data =  @candidate.resume.download
      file_name = @candidate.resume.filename.to_s
      attachments[file_name] = resume_data
    end
  end
end
