/// Module: transcript
module transcript::transcript {

    public struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    public struct Folder has key {
        id: UID,
        transcript: WrappableTranscript,
        intended_address: address
    }

    public struct TeacherCap has key {
        id: UID
    }

    // Error code for when a non-intended address tries to unpack the transcript wrapper
    const ENotIntendedAddress: u64 = 1;

    /// Module inializer is called only once on module publish
    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            TeacherCap {
                id: object::new(ctx)
            },
            tx_context::sender(ctx)
        )
    }

    public fun add_additional_teacher(
        _: &TeacherCap,
        new_teacher_address: address,
        ctx: &mut TxContext,
    ) {
        transfer::transfer(
            TeacherCap {
                id: object::new(ctx)
            },
            new_teacher_address
        )
    }

    public entry fun create_wrappable_transcript_object(
        _: &TeacherCap,
        history: u8,
        math: u8,
        literature: u8,
        ctx: &mut TxContext,
    ) {
        let wrappableTranscript = WrappableTranscript {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(wrappableTranscript, tx_context::sender(ctx))
    }

    // You are allowed to retrieve the score but cannot modify it
    public fun view_score(transcriptObject: &WrappableTranscript): u8 {
        transcriptObject.literature
    }

    // You are allowed to view and edit the score but not allowed to delete it
    public entry fun update_score(_: &TeacherCap, transcriptObject: &mut WrappableTranscript, score: u8) {
        transcriptObject.literature = score
    }

    // You are allowed to fo anything with the score, including view, edit, or delete the entire transcript itself.
    public entry fun delete_transcript(_: &TeacherCap, transcriptObject: WrappableTranscript) {
        let WrappableTranscript { id, history: _, math: _, literature: _ } = transcriptObject;
        object::delete(id);
    }

    public entry fun request_transcript(
        transcript: WrappableTranscript,
        intended_address: address,
        ctx: &mut TxContext,
    ) {
        let folder = Folder {
            id: object::new(ctx),
            transcript,
            intended_address
        };
        transfer::transfer(folder, intended_address)
    }

    public entry fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
        // Check that the person unpacking the transcript is the intended viewer
        assert!(tx_context::sender(ctx) == folder.intended_address, ENotIntendedAddress);
        let Folder {
            id,
            transcript,
            intended_address: _,
        } = folder;
        transfer::transfer(transcript, tx_context::sender(ctx));
        object::delete(id)
    }
}
// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
