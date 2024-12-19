/// Module: transcript
module transcript::transcript {

    public struct Transcript {
        history: u8,
        math: u8,
        literature: u8,
    }

    public struct TranscriptObject has key {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let transcriptObject =  TranscriptObject {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(transcriptObject, tx_context::sender(ctx))
    }

    // You are allowed to retrieve the score but cannot modify it
    public fun view_score(transcriptObject: &TranscriptObject): u8 {
        transcriptObject.literature
    }

    // You are allowed to view and edit the score but not allowed to delete it
    public fun update_score(transcriptObject: &mut TranscriptObject, score: u8) {
        transcriptObject.literature = score
    }

    // You are allowed to fo anything with the score, including view, edit, or delete the entire transcript itself.
    public fun delete_transcript(transcriptObject: TranscriptObject) {
        let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
        object::delete(id);
    }


}

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions


