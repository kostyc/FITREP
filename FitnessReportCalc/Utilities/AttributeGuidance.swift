//
//  AttributeGuidance.swift
//  FitnessReportCalc
//
//  Created by Justin Seignemartin on 3/4/25.
//
import Foundation

// Attribute Guidance
struct AttributeGuidance {
    static let attributeNames = [
        "Mission Accomplishment", "Proficiency", "Courage", "Effectiveness Under Stress",
        "Initiative", "Leading Subordinates", "Developing Subordinates", "Setting the Example",
        "Ensuring Well-Being of Subordinates", "Communication Skill", "Professional Military Education (PME)",
        "Decision-Making Ability", "Judgment", "Evaluation of Subordinates"
    ]

    static let attributeDetails: [String: (definition: String, ratings: [String: String])] = [
        "Mission Accomplishment": (
            definition: "Results achieved during the reporting period. How well those duties inherent to a Marine’s billet, plus all additional duties, formally and informally assigned, were carried out. Reflects a Marine’s aptitude competence, and commitment to the unit’s success above personal reward. Indicators are time and resource management, task prioritization, and tenacity to achieve positive ends consistently.",
            ratings: [
                "A": "Fails to complete missions: outcomes are inadequate or nonexistent",
                "B": "Meets requirements of billet and additional duties. Aptitude, commitment, and competence meet expectations. Results maintain status quo.",
                "C": "Not quite B not quite D",
                "D": "Consistently produces quality results while measurably improving unit performance. Habitually makes effective use of time and resources. Improves billet procedures and products. Positive impact extends beyond billet expectations.",
                "E": "Not quite B not quite D",
                "F": "Results far surpass expectations. Recognizes and exploits new resources; creates opportunities. Emulated; sought after as expert with influence beyond unit. Impact significant; innovative approaches to problems produce significant gains in quality and efficiency.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Proficiency": (
            definition: "Demonstrates technical knowledge and practical skill in the execution of the Marine’s overall duties. Combines training, education, and experience. Translates skills into actions which contribute to accomplishing tasks and missions. Imparts knowledge to others. Grade dependent.",
            ratings: [
                "A": "Lacks basic competence in MOS or billet duties; unable to perform effectively",
                "B": "Competent. Possesses the requisite range of skills and knowledge commensurate with grade and experience. Understands and articulates basic functions related to mission accomplishment.",
                "C": "Not quite B not quite D",
                "D": "Demonstrates mastery of all required skills. Expertise, education and experience consistently enhance mission accomplishment. Innovative troubleshooter and problem solver. Effectively imparts skills to subordinates.",
                "E": "Not quite B not quite D",
                "F": "True expert in field. Knowledge and skills impact far beyond those of peers. Translates broad-based education and experience into forward thinking, innovative actions. Makes immeasurable impact on mission accomplishment. Peerless teacher, selflessly imparts expertise to subordinates, peers, and seniors.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Courage": (
            definition: "Moral and physical strength to overcome danger, fear, difficulty or anxiety. Personal acceptance of responsibility and accountability, placing conscience over competing interests regardless of consequences. Conscious, overriding decision to risk bodily harm or death to accomplish the mission or save others. The will to persevere despite uncertainty.",
            ratings: [
                "A": "Avoids adversity or freezes when faced with moral/physical challenges",
                "B": "Demonstrates inner strength and acceptance of responsibility commensurate with scope of duties and experience. Willing to face moral or physical challenges in pursuit of mission accomplishment.",
                "C": "Not quite B not quite D",
                "D": "Guided by conscience in all actions. Proven ability to overcome danger, fear, difficulty or anxiety. Exhibits bravery in the face of adversity and uncertainty. Not deterred by morally difficult situations or hazardous responsibilities.",
                "E": "Not quite B not quite D",
                "F": "Uncommon bravery and capacity to overcome obstacles and inspire others in the face of moral dilemma or life-threatening danger. Demonstrated under the most adverse conditions. Selfless. Always places conscience over competing interests regardless of physical or personal consequences.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Effectiveness Under Stress": (
            definition: "Thinking, functioning, and leading effectively under conditions of physical and/or mental pressure. Maintaining composure appropriate for the situation, while displaying steady purpose of action, enabling one to inspire others while continuing to lead under adverse conditions. Physical and emotional strength, resilience, and endurance are elements.",
            ratings: [
                "A": "Crumbles under pressure, unable to function when challenged",
                "B": "Exhibits discipline and stability under pressue. Judgment and effective problem-solving skills are evident.",
                "C": "Not quite B not quite D",
                "D": "Consistently demonstrates maturity, mental agility, and willpower during periods of adversity. Provides order to chaos through the application of intuition, problem-solving skills, and leadership. Composure reassures others.",
                "E": "Not quite D not quite F",
                "F": "Demonstrates seldom-matched presence of mind under the most demanding circumstances. Stabilizes any situation through the resolute and timely application of direction, focus, and personal presence.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Initiative": (
            definition: "Action in the absence of specific direction. Seeing what needs to be done and acting without prompting. The instinct to begin a task and follow through energetically on one’s own accord. Being creative, proactive and decisive. Transforming opportunity into action.",
            ratings: [
                "A": "Takes no action without explicit orders, even when needed",
                "B": "Demonstrates willingness to take action in the Acts commensurate with grade, training, and absence of specific direction. experience.",
                "C": "Not quite B not quite D",
                "D": "Self-motivated and action-oriented. Foresight and energy consistently transform opportunity into action.  Develops and pursues creative, innovative solutions. Acts without prompting. Self-starter.",
                "E": "Not quite D not quite F",
                "F": "Highly motivated and proactive. Displays exceptional awareness of surroundings and environment. Uncanny ability to anticipate mission requirements and quickly formulate original, far-reaching solutions. Always takes decisive, effective action.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Leading Subordinates": (
            definition: "The inseparable relationship between leader and led. The application of leadership principles to provide direction and motivate subordinates. Using authority, persuasion, and personality to influence subordinates to accomplish assigned tasks. Sustaining motivation and morale while maximizing subordinates’ performance.",
            ratings: [
                "A": "Fails to lead; subordinates are directionless or ineffective",
                "B": "Engaged; provides instructions and directs execution. Seeks to accomplish mission in ways that sustain motivation and morale. Actions contribute to unit effectiveness.",
                "C": "Not quite B not quite D",
                "D": "Achieves a highly effective balance between direction and delegation. Effectively tasks subordinates and clearly delineates standards expected. Enhances performance through constructive supervision. Fosters motivation and enhances morale. Builds and sustains teams that successfully meet mission requirements. Encourages initiative and candor among subordinates.",
                "E": "Not quite D not quite F",
                "F": "Promotes creativity and energy among subordinates by striking the ideal balance of direction and delegation. Achieves highest levels of performance from subordinates by encouraging individual initiative. Engenders willing subordination, loyalty, and trust that allow subordinates to overcome their perceived limitations. Personal leadership fosters highest levels of motivation and morale, ensuring mission accomplishment even in the most difficult circumstances.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Developing Subordinates": (
            definition: "Commitment to train, educate, and challenge all Marines regardless of race, religion, ethnic background, or gender. Mentorship. Cultivating professional and personal development of subordinates. Developing team players and esprit de corps. Ability to combine teaching and coaching. Creating an atmosphere tolerant of mistakes in the course of learning.",
            ratings: [
                "A": "Neglects training; subordinates stagnate or regress",
                "B": "Maintains an environment that allows personal and professional development. Ensures subordinates participate in all mandated development programs.",
                "C": "Not quite B not quite D",
                "D": "Develops and institutes innovative programs, to include PME, that emphasize personal and professional development of subordinates. Challenges subordinates to exceed their perceived potential thereby enhancing unit morale and effectiveness. Creates an environment where all Marines are confident to learn through trial and error. As a mentor, prepares subordinates for increased responsibilities and duties.",
                "E": "Not quite D not quite F",
                "F": "Widely recognized and emulated as a teacher, coach and leader. Any Marine would desire to serve with this Marine because they know they will grow personally and professionally. Subordinate and unit performance far surpassed expected results due to MRO’s mentorship and team building talents. Attitude toward subordinate development is infectious, extending beyond the unit.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Setting the Example": (
            definition: "The most visible facet of leadership: how well a Marine serves as a role model for all others. Personal action demonstrates the highest standards of conduct, ethical behavior, fitness, and appearance. Bearing, demeanor, and self-discipline are elements.",
            ratings: [
                "A": "Sets a negative example—poor conduct, fitness, or discipline",
                "B": "Maintains Marine Corps standards for appearance, weight, and uniform wear. Sustains required level of",
                "C": "Not quite B not quite D",
                "D": "Personal conduct on and off duty reflects highest Marine Corps standards of integrity, bearing, and appearance. Character is exceptional. Actively seeks self-improvement in wide-ranging areas.  Dedication to duty and professional example encourage others’ self-improvement efforts.",
                "E": "Not quite D not quite F",
                "F": "Model Marine, frequently emulated. Exemplary conduct, behavior, and actions are tone-setting. An inspiration to subordinates, peers, and seniors. Remarkable dedication to improving self and others.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Ensuring Well-Being of Subordinates": (
            definition: "Genuine interest in the well-being of Marines. Efforts enhance subordinates’ ability to concentrate/focus on unit mission accomplishment. Concern for family readiness is inherent. The importance placed on welfare of subordinates is based on the belief that Marines take care of their own.",
            ratings: [
                "A": "Ignores subordinates’ welfare, causing harm or neglect",
                "B": "Deals confidently with issues pertinent to subordinate welfare and recognizes suitable courses of action that support subordinates’ well-being. Applies available resources, allowing subordinates to effectively concentrate on the mission.",
                "C": "Not quite B not quite D",
                "D": "Instills and/or reinforces a sense of responsibility among junior Marines for themselves and their subordinates. Actively fosters the development of and uses support systems for subordinates which improve their ability to contribute to unit mission accomplishment. Efforts to enhance subordinate welfare improve the unit’s ability to accomplish its mission.",
                "E": "Not quite D not quite F",
                "F": "Noticeably enhances subordinate well-being, resulting in a measurable increase in unit effectiveness. Maximizes unit and base resources to provide subordinates with the best support available. Proactive approach serves to energize unit members to 'take care of their own,' thereby correcting potential problems before they can hinder subordinates’ effectiveness. Widely recognized for techniques and policies that produce results and build morale. Builds strong family atmosphere. Puts motto “Mission first, Marines always” into action.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Communication Skill": (
            definition: "The efficient transmission and receipt of thoughts and ideas that enable and enhance leadership. Equal importance given to listening, speaking, writing, and critical reading skills. Interactive, allowing one to perceive problems and situations, provide concise guidance, and express complex ideas in a form easily understood by everyone. Allows subordinates to ask questions, raise issues and concerns, and venture opinions. Contributes to a leader’s ability to motivate as well as counsel.",
            ratings: [
                "A": "Cannot convey ideas; communication fails entirely",
                "B": "Skilled in receiving and conveying information. Communicates effectively in performance of duties.",
                "C": "Not quite B not quite D",
                "D": "Clearly articulates thoughts and ideas, verbally and in writing. Communication in all forms is accurate, intelligible, concise, and timely. Communicates with clarity and verve, ensuring understanding of intent or purpose. Encourages and considers the contributions of others.",
                "E": "Not quite D not quite F",
                "F": "Highly developed facility in verbal communication. Adept in composing written documents of the highest quality. Combines presence and verbal skills that engender confidence and achieve understanding irrespective of the setting, situation, or size of the group addressed. Displays an intuitive sense of when and how to listen.",
                "G": "Water walker",
                "H": "CNot Observed"
            ]
        ),
        "Professional Military Education (PME)": (
            definition: "Commitment to intellectual growth in ways beneficial to the Marine Corps. Increases the breadth and depth of warfighting and leadership aptitude. Resources include resident schools; professional qualifications and certification processes; non-resident and other extension courses; civilian educational institution coursework; a personal reading program that includes (but is not limited to) selections from the Marine Corps Professional Reading Program; participation in discussion groups and military societies; and involvement in learning through new technologies.",
            ratings: [
                "A": "Avoids PME, no effort toward military knowledge",
                "B": "Maintains currency in required military skills and related developments. Has completed or is enrolled in appropriate level of PME for grade and level of experience. Recognizes and understands new and creative approaches to service issues. Remains abreast of contemporary concepts and issues.",
                "C": "Not quite B not quite D",
                "D": "PME outlook extends beyond MOS and required education. Develops and follows a comprehensive personal program which includes broadened professional reading and/or academic course work; advances new concepts and ideas.",
                "E": "Not quite D not quite F",
                "F": "Dedicated to lifelong learning. As a result of active and continuous efforts, widely recognized as an intellectual leader in professionally related topics. Makes time for study and takes advantage of all resources and programs. Introduces new and creative approaches to service issues. Engages in a broad spectrum of forums and dialogues.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Decision-Making Ability": (
            definition: "Viable and timely problem solution. Contributing elements are judgment and decisiveness. Decisions reflect the balance between an optimal solution and a satisfactory, workable solution that generates tempo. Decisions are made within the context of the commander’s established intent and the goal of mission accomplishment. Anticipation, mental agility, intuition, and success are inherent.",
            ratings: [
                "A": "Makes poor or no decisions, paralyzing progress",
                "B": "Makes sound decisions leading to mission accomplishment. Actively collects and evaluates information and weighs alternatives to achieve timely results. Confidently approaches problems; accepts responsibility for outcomes.",
                "C": "Not quite B not quite D",
                "D": "Demonstrates mental agility; effectively prioritizes and solves multiple complex problems. Analytical abilities enhanced by experience, education, and intuition. Anticipates problems and implements viable, long-term solutions. Steadfast, willing to make difficult decisions.",
                "E": "Not quite D not quite F",
                "F": "Widely recognized and sought after to resolve the most critical, complex problems. Seldom matched analytical and intuitive abilities; accurately foresees unexpected problems and arrives at well-timed decisions despite fog and friction. Completely confident approach to all problems. Masterfully strikes a balance between the desire for perfect knowledge and greater tempo.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Judgment": (
            definition: "The discretionary aspect of decision-making. Draws on core values, knowledge, and personal experience to make wise choices. Comprehends the consequences of contemplated courses of action.",
            ratings: [
                "A": "Lacks judgment, choices are reckless or unethical",
                "B": " Majority of judgments are measured, circumspect, relevant, and correct.",
                "C": "Not quite B not quite D",
                "D": "Decisions are consistent and uniformly correct, tempered by consideration of their consequences. Able to identify, isolate, and assess relevant factors in the decision making process. Opinions sought by others. Subordinates personal interests in favor of impartiality.",
                "E": "Not quite D not quite F",
                "F": "Decisions reflect exceptional insight and wisdom beyond this Marine’s experience. Counsel sought by all; often an arbiter. Consistent, superior judgment inspires the confidence of seniors.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        ),
        "Evaluation of Subordinates": (
            definition: "The extent to which the MRO, serving as a reporting official, conducted, or required others to conduct, accurate, uninflated, and timely evaluations.",
            ratings: [
                "A": "Fails to evaluate, assessments are absent or unfair",
                "B": "Occasionally submitted untimely or administratively incorrect evaluations. As RS, submitted one or more reports that contained inflated markings. As RO, concurred with one or more reports from subordinates that were returned by HQMC for inflated marking.",
                "C": "Not quite B not quite D",
                "D": "Prepared uninflated evaluations which were consistently submitted on time. Evaluations accurately described performance and character. Evaluations contained no inflated markings. No reports returned by RO or HQMC for inflated marking. No subordinates’ reports returned by HQMC for inflated marking. Few, if any, reports were returned by RO or HQMC for administrative errors. Section Cs were void of superlatives. Justifications were specific, verifiable, substantive, and where possible, quantifiable and supported the markings given.",
                "E": "Not quite D not quite F",
                "F": "No reports submitted late. No reports returned by either RO or HQMC for administrative correction or inflated markings. No subordinate reports returned by HQMC for administrative correction or inflated markings. Returned procedurally or administratively incorrect reports to subordinates for correction. As RO, non-concurred with all inflated reports.",
                "G": "Water walker",
                "H": "Not Observed"
            ]
        )
    ]
}
