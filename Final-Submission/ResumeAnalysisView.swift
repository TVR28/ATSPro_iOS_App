import SwiftUI
import UIKit
import GoogleGenerativeAI  // Assuming this is the correct module name

struct TabItem {
    var icon: String
    var text: String
}

extension View {
    func exportAsPDF() -> Data {
        let pdfPageSize = CGRect(x: 0, y: 0, width: 595, height: 842)  // A4 size
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageSize, nil)
        UIGraphicsBeginPDFPage()
        
        let pdfContext = UIGraphicsGetCurrentContext()!
        let view = UIHostingController(rootView: self)
        view.view.frame = pdfPageSize
        view.view.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()

        return pdfData as Data
    }
}

struct ResultsView: View {
    var jobRole: String
    var jobDescription: String
    var resumeText: String

    @State private var selectedTabIndex = 0
    @State private var resetChat = false
    @State private var geminiResponseText: String = "Loading response..."

    let tabItems: [TabItem] = [
        TabItem(icon: "doc.text.image", text: "Overview"),
        TabItem(icon: "key.fill", text: "Missing Keywords"),
        TabItem(icon: "lightbulb.fill", text: "Suggestions"),
        TabItem(icon: "person.fill.questionmark", text: "Interview Prep")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom Tab Bar
                HStack {
                    ForEach(0..<tabItems.count, id: \.self) { index in
                        Button(action: {
                            selectedTabIndex = index
                            loadGeminiResponse(for: index)
                        }) {
                            VStack {
                                Image(systemName: tabItems[index].icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedTabIndex == index ? .blue : .gray)
                                Text(tabItems[index].text)
                                    .font(.caption)
                                    .foregroundColor(selectedTabIndex == index ? .blue : .gray)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .background(Color.white.edgesIgnoringSafeArea(.top))

                Text("Google Gemini Response")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(geminiResponseText)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding([.leading, .trailing, .bottom])

                // Integrating ChatView here
                ChatView(chatContext: tabItems[selectedTabIndex].text.lowercased())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        if resetChat {
                            resetChat = false
                        }
                    }

                Spacer()
            }
            .navigationTitle("Generated Responses")
//            .navigationBarItems(trailing: Button(action: {
//                // Download action
//            }) 
//                {
//                Image(systemName: "arrow.down.circle")
//                Text("Download")
//            })
        }
        .onAppear {
            clearAllChatsAndResponses()
            resetChat = true
            loadGeminiResponse(for: selectedTabIndex)
        }
    }

    func loadGeminiResponse(for index: Int) {
        let prompts = [
            " You are a professional and experienced Application Tracking System(ATS) with a deep understanding of \(jobRole) fields. Analyze the provided resume and job description (JD). Provide a detailed analysis (200-300 words) of how the resume aligns with the JD, highlighting key areas of strength, relevant experiences, and qualifications. Discuss any notable achievements or skills that are particularly well-matched to the job requirements.Here is the resume content : \(resumeText). Here is the job description : \(jobDescription). Your Response Should have the following structure Example: Note: Only Mention and Analyze the content of the provided resume text. Make sure Nothing additional is added outside the provided text. Resume Analysis and Alignment with Job Description: Overview: The resume presents a strong background in software engineering, with a particular emphasis on full-stack development and cloud technologies. Strengths: - Technical Proficiency: Proficient in key programming languages such as Python, JavaScript, and Java, aligning well with the job's technical requirements. - Project Experience: Showcases several projects that demonstrate the ability to design, develop, and deploy scalable software solutions, mirroring the JD's emphasis on hands-on experience. Relevant Experiences: (Highlight only the things that are present in the resume.) - Lead Developer Role: Led a team in developing a SaaS application using microservices architecture, directly relevant to the job's focus on leadership and microservices. - Cloud Solutions Architect: Experience in designing cloud infrastructure on AWS, aligning with the JD's requirement for cloud computing skills. Provide response in 200-250 words.",
            
            
            "You are a professional and experienced ATS(Application Tracking System) focused exclusively on the \(jobRole) field. Your task is to evaluate the resume strictly based on the provided job description and resume content. It is critical to only identify and list the keywords and phrases that have a direct match between the resume and the JD. Highlight any crucial keywords or skills required for the job that are absent in the resume. Based on your analysis, provide a percentage match. Important: Your analysis must strictly adhere to the content provided below. Do not infer or add any keywords, skills, or technologies not explicitly mentioned in these texts. Re-evaluate the texts to ensure accuracy. Recheck before you provide your response. Resume Content: \(resumeText) Job Description: \(jobDescription). Never provide anything which is neither present in resume content nor job description.Output should strictly follow this structure: Percentage Match: [Provide percentage] Matched Keywords: - Skills: [List only the matched skills found in both the job description and resume content. recheck before you provide your response] - Technologies: [List only the matched technologies found in both the job description and resume. Recheck before you provide your response] - Methodologies: [List only the matched methodologies found in both the job description and resume. Recheck before you provide your response]. Missing Keywords:  - [List the skills or technologies crucial for the role found in the job description but not in the resume. Recheck before you provide your response]. Final Thoughts: - [Provide a brief assessment focusing on the alignment, matched keywords, missing elements, and percentage match. Reinforce the instruction to only mention elements present in the provided texts. Recheck before you provide your response]. Provide response in 200-250 words.",
            
            
            "You are a professional and experienced ATS(Application Tracking System) with a deep understanding of \(jobRole) fields. Based on the analysis of the resume and the job description, suggest specific improvements and additions to the candidate's skill set (200-300 words). Identify areas where the candidate falls short and recommend actionable steps or resources for acquiring or enhancing the necessary skills. Highlight the importance of these skills in the context of the targeted job role. Here is the resume content : \(resumeText). Here is the job description : \(jobDescription). Your Response Should have the following structure. Example: Note: Only Mention and Analyze the content of the provided resume text. Make sure Nothing additional is added outside the provided text . Skills Improvement and Addition Suggestions: To further align your resume with the job requirements and the evolving trends in software engineering, consider the following improvements: Expand Knowledge in Emerging Technologies: - Dive into Machine Learning and Big Data Analytics; consider online courses or projects that demonstrate practical application. - Familiarize yourself with Blockchain Technology, given its growing impact on secure and decentralized systems. Enhance Cloud Computing Skills: - Gain deeper expertise in cloud services beyond AWS, such as Microsoft Azure or Google Cloud Platform, to showcase versatility. - Strengthen Soft Skills: Leadership and project management skills are highly valued; consider leading more projects or taking courses in Agile and Scrum methodologies. Provide response in 200-250 words.",
            
            
            "You are a professional and experienced ATS(Application Tracking System) with a deep understanding of {role} fields. Review the resume's bullet points in light of the job description. Provide targeted suggestions on how to edit existing bullet points to better align with the job requirements. Focus on enhancing clarity, relevance, and impact by incorporating keywords from the JD and emphasizing achievements and skills that are most pertinent to the job. Here is the resume content : {text} Here is the job description : {jd} Your Response Should have the following structure. Example: Note: Only Mention and Analyze the content of the provided resume text. Make sure Nothing additional is added outside the provided text. Resume Customization Tips for Better Alignment with Job Description: Tailor Bullet Points: - Current: (Developed a web application using React and Node.js.) - Revised: (Engineered a scalable web application using React and Node.js, incorporating microservices architecture to enhance modularity and deployability, directly supporting team objectives in agile development environments.) Highlight Specific Achievements:  - Current: (Designed cloud infrastructure for various projects.) - Revised: (Strategically designed and deployed robust cloud infrastructure on AWS for 3 enterprise-level projects, achieving a 20% improvement in deployment efficiency and cost reduction.) Incorporate Missing Keywords: If you have experience with Machine Learning, add a bullet point like: (Implemented machine learning algorithms to automate data processing tasks, resulting in a 30% reduction in processing times.). Provide response in 200-250 words."
        ]
        
        let prompt = prompts[index]
        let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.geminiKey)
        
        Task {
            do {
                let response = try await model.generateContent(prompt)
                DispatchQueue.main.async {
                    geminiResponseText = response.text?.replacingOccurrences(of: "*", with: "") ?? "Failed to generate a response. Please try again."
                }
            } catch {
                DispatchQueue.main.async {
                    geminiResponseText = "Failed to generate a response. Please try again."
                }
            }
        }
    }
    
    func clearAllChatsAndResponses() {
            UserDefaults.standard.setValue("", forKey: "overviewChatMessages")
            UserDefaults.standard.setValue("", forKey: "missingKeywordsChatMessages")
            UserDefaults.standard.setValue("", forKey: "suggestionsChatMessages")
            UserDefaults.standard.setValue("", forKey: "interviewPrepChatMessages")
        }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(jobRole: "Software Developer", jobDescription: "Develop cutting-edge software solutions.", resumeText: "Experienced in software development.")
    }
}
