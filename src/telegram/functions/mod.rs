pub mod help;
pub mod start;

use crate::telegram::bot::Command;
use crate::telegram::functions;
use std::error::Error;
use teloxide::{prelude::*, types::*};

pub async fn commands(
    bot: Bot,
    me: Me,
    msg: Message,
    cmd: Command,
) -> Result<(), Box<dyn Error + Send + Sync + 'static>> {
    let _ = match cmd {
        Command::Start => functions::start::command(&bot, &msg).await,
        Command::Help => functions::help::command(&bot, &msg, &cmd).await,
    };

    Ok(())
}
